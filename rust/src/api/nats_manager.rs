use async_nats::{self, Client};
use flutter_rust_bridge::DartFnFuture;
use std::time::Duration;
use anyhow::Result;
use std::sync::Arc;
use tokio::sync::Mutex;
use once_cell::sync::Lazy;
use tokio::sync::RwLock;
use std::collections::HashMap;
use tokio_stream::StreamExt;

// A thread-safe wrapper around the NATS client
static NATS_CLIENT: Lazy<Arc<Mutex<Option<Client>>>> = Lazy::new(|| {
    Arc::new(Mutex::new(None))
});

// Store active subscription information
type SubscriptionId = String;

// Use a single Mutex to guard all subscription processes
static SUBSCRIPTION_CONTROL: Lazy<Arc<Mutex<()>>> = Lazy::new(|| {
    Arc::new(Mutex::new(()))
});

// Store active subscriptions
static SUBSCRIPTIONS: Lazy<Arc<RwLock<HashMap<SubscriptionId, async_nats::Subscriber>>>> = Lazy::new(|| {
    Arc::new(RwLock::new(HashMap::new()))
});

// Store a flag for each subscription indicating if it should continue
static SUBSCRIPTION_ACTIVE: Lazy<Arc<RwLock<HashMap<SubscriptionId, bool>>>> = Lazy::new(|| {
    Arc::new(RwLock::new(HashMap::new()))
});

/// Initializes flutter_rust_bridge's default utilities.
#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

/// Connects to a NATS server and calls appropriate callback based on result.
#[flutter_rust_bridge::frb]
pub async fn connect_to_nats(
    end_point: String,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    let result = async_nats::connect(end_point).await;

    let mut client_guard = NATS_CLIENT.lock().await;
    match result {
        Ok(client) => {
            *client_guard = Some(client);
            drop(client_guard); // Release the lock before the callback
            on_success(true).await;
        }
        Err(e) => {
            drop(client_guard); // Release the lock before the callback
            on_failure(e.to_string()).await;
        }
    }
}

/// Disconnects from the NATS server if currently connected.
///
/// # Arguments
///
/// * `on_success` - Callback function called when disconnect is successful
/// * `on_failure` - Callback function called with error message if disconnect fails
#[flutter_rust_bridge::frb]
pub async fn disconnect_from_nats(
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // First, mark all subscriptions as inactive
    {
        let mut active_map = SUBSCRIPTION_ACTIVE.write().await;
        for (_, active) in active_map.iter_mut() {
            *active = false;
        }
    }

    // Wait for subscription processing to complete
    let _lock = SUBSCRIPTION_CONTROL.lock().await;

    // Clear all subscriptions
    {
        let mut subs = SUBSCRIPTIONS.write().await;
        subs.clear();
    }

    // Clear active flags
    {
        let mut active_map = SUBSCRIPTION_ACTIVE.write().await;
        active_map.clear();
    }

    // Disconnect the client
    let mut client_guard = NATS_CLIENT.lock().await;
    match client_guard.take() {
        Some(client) => {
            // Drop the client to close the connection
            drop(client);
            drop(client_guard); // Release the lock before the callback
            on_success(true).await;
        },
        None => {
            drop(client_guard); // Release the lock before the callback
            on_failure("Not connected to any NATS server".to_string()).await;
        }
    }
}

/// Sends a request to NATS server and returns the response.
///
/// # Arguments
///
/// * `subject` - The subject to publish the request to
/// * `payload` - The message payload as a string
/// * `timeout_ms` - Request timeout in milliseconds
///
/// # Returns
///
/// * `Result<String, String>` - The response payload or an error message
#[flutter_rust_bridge::frb]
pub async fn send_request(
    subject: String,
    payload: String,
    timeout_ms: u64,
) -> Result<String, String> {
    let client_guard = NATS_CLIENT.lock().await;

    // Check if we have a client
    let client = match &*client_guard {
        Some(client) => client,
        None => return Err("Not connected to NATS server".to_string()),
    };

    // Create payload as bytes
    let payload_bytes = payload.into_bytes();
    let timeout = Duration::from_millis(timeout_ms);

    // Clone the client to avoid holding the lock during the request
    let client_clone = client.clone();
    drop(client_guard);

    // Send request with timeout
    let response = tokio::time::timeout(
        timeout,
        client_clone.request(subject, payload_bytes.into()),
    )
        .await
        .map_err(|_| "Request timed out".to_string())?
        .map_err(|e| e.to_string())?;

    // Convert response payload to string
    String::from_utf8(response.payload.to_vec())
        .map_err(|e| format!("Invalid UTF-8 in response: {}", e))
}

/// Sends a request to NATS server and handles response via callbacks.
///
/// # Arguments
///
/// * `subject` - The subject to publish the request to
/// * `payload` - The message payload as a string
/// * `timeout_ms` - Request timeout in milliseconds
/// * `on_success` - Callback function called with response on success
/// * `on_failure` - Callback function called with error message on failure
#[flutter_rust_bridge::frb]
pub async fn _send_request_with_callbacks(
    subject: String,
    payload: String,
    timeout_ms: u64,
    on_success: impl Fn(String) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // Use the _sendRequest function and handle its result with callbacks
    match send_request(subject, payload, timeout_ms).await {
        Ok(response) => {
            on_success(response).await;
        }
        Err(error) => {
            on_failure(error).await;
        }
    }
}

/// Publishes a message to the specified subject.
///
/// # Arguments
///
/// * `subject` - The subject to publish the message to
/// * `payload` - The message payload as a string
/// * `on_success` - Callback function called when publish is successful
/// * `on_failure` - Callback function called with error message if publish fails
#[flutter_rust_bridge::frb]
pub async fn publish(
    subject: String,
    payload: String,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    let client_guard = NATS_CLIENT.lock().await;

    // Check if we have a client
    let client = match &*client_guard {
        Some(client) => client.clone(),
        None => {
            drop(client_guard);
            on_failure("Not connected to NATS server".to_string()).await;
            return;
        }
    };

    drop(client_guard);

    // Create payload as bytes
    let payload_bytes = payload.into_bytes();

    // Publish the message
    match client.publish(subject, payload_bytes.into()).await {
        Ok(_) => {
            on_success(true).await;
        },
        Err(e) => {
            on_failure(e.to_string()).await;
        }
    }
}

/// Subscribes to a subject and receives messages via a callback.
///
/// This function will continuously poll for messages on the given subject
/// and call the provided callbacks when messages are received.
///
/// # Arguments
///
/// * `subject` - The subject to subscribe to (can include wildcards)
/// * `subscription_id` - A unique identifier for this subscription
/// * `max_messages` - Maximum number of messages to process (0 for unlimited)
/// * `on_message` - Callback function called when a message is received
/// * `on_success` - Callback function called when subscription is successful
/// * `on_error` - Callback function called if subscription fails
/// * `on_done` - Callback function called when subscription ends
#[flutter_rust_bridge::frb]
pub async fn subscribe(
    subject: String,
    subscription_id: String,
    max_messages: u32,
    on_message: impl Fn(String, String) -> DartFnFuture<()>,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_error: impl Fn(String) -> DartFnFuture<()>,
    on_done: impl Fn() -> DartFnFuture<()>,
) {
    // Get the client
    let client_guard = NATS_CLIENT.lock().await;
    let client = match &*client_guard {
        Some(client) => client.clone(),
        None => {
            drop(client_guard);
            on_error("Not connected to NATS server".to_string()).await;
            return;
        }
    };
    drop(client_guard);

    // Check if we already have this subscription
    {
        let subs = SUBSCRIPTIONS.read().await;
        if subs.contains_key(&subscription_id) {
            drop(subs);
            on_error(format!("Subscription '{}' already exists", subscription_id)).await;
            return;
        }
    }

    // Create the subscription
    match client.subscribe(subject.clone()).await {
        Ok(subscriber) => {
            // Store the subscription and mark it as active
            {
                let mut subs = SUBSCRIPTIONS.write().await;
                subs.insert(subscription_id.clone(), subscriber);
            }
            {
                let mut active_map = SUBSCRIPTION_ACTIVE.write().await;
                active_map.insert(subscription_id.clone(), true);
            }

            // Notify successful subscription
            on_success(true).await;

            // Start processing in the current task (no tokio::spawn)
            // This avoids thread safety issues with the callbacks
            poll_subscription(
                subject,
                subscription_id,
                max_messages,
                on_message,
                on_error,
                on_done,
            ).await;
        },
        Err(e) => {
            on_error(format!("Failed to subscribe: {}", e)).await;
        }
    }
}

/// Internal function to poll a subscription for messages
async fn poll_subscription(
    subject: String,
    subscription_id: String,
    max_messages: u32,
    on_message: impl Fn(String, String) -> DartFnFuture<()>,
    on_error: impl Fn(String) -> DartFnFuture<()>,
    on_done: impl Fn() -> DartFnFuture<()>,
) {
    // Acquire lock for this subscription's processing
    let _control_lock = SUBSCRIPTION_CONTROL.lock().await;

    let mut message_count = 0;
    let unlimited = max_messages == 0;

    loop {
        // Check if we should continue (subscription is active)
        let should_continue = {
            let active_map = SUBSCRIPTION_ACTIVE.read().await;
            active_map.get(&subscription_id).copied().unwrap_or(false)
        };

        if !should_continue {
            break;
        }

        // Check message count limit
        if !unlimited && message_count >= max_messages {
            break;
        }

        // Get the next message
        let maybe_msg = {
            let mut subs = SUBSCRIPTIONS.write().await;
            if let Some(sub) = subs.get_mut(&subscription_id) {
                // Try to get the next message with a small timeout
                tokio::time::timeout(
                    Duration::from_millis(100),
                    sub.next()
                ).await.unwrap_or_else(|_| None)
            } else {
                None // Subscription doesn't exist anymore
            }
        };

        // Process the message if we got one
        match maybe_msg {
            Some(msg) => {
                // Convert payload to string
                match String::from_utf8(msg.payload.to_vec()) {
                    Ok(payload) => {
                        on_message(subject.clone(), payload).await;
                        message_count += 1;
                    },
                    Err(e) => {
                        on_error(format!("Invalid UTF-8 in message: {}", e)).await;
                    }
                }
            },
            None => {
                // No message, check if subscription still exists
                let sub_exists = {
                    let subs = SUBSCRIPTIONS.read().await;
                    subs.contains_key(&subscription_id)
                };

                if !sub_exists {
                    break;
                }

                // Small delay to avoid busy-waiting
                tokio::time::sleep(Duration::from_millis(50)).await;
            }
        }
    }

    // Subscription ended, clean up
    {
        let mut subs = SUBSCRIPTIONS.write().await;
        subs.remove(&subscription_id);
    }
    {
        let mut active_map = SUBSCRIPTION_ACTIVE.write().await;
        active_map.remove(&subscription_id);
    }

    // Notify completion
    on_done().await;
}

/// Unsubscribes from a subject.
///
/// # Arguments
///
/// * `subscription_id` - The unique identifier of the subscription to cancel
/// * `on_success` - Callback function called when unsubscribe is successful
/// * `on_failure` - Callback function called with error message if unsubscribe fails
#[flutter_rust_bridge::frb]
pub async fn unsubscribe(
    subscription_id: String,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // Mark the subscription as inactive
    let exists = {
        let mut active_map = SUBSCRIPTION_ACTIVE.write().await;
        if let Some(active) = active_map.get_mut(&subscription_id) {
            *active = false;
            true
        } else {
            false
        }
    };

    if exists {
        on_success(true).await;
    } else {
        on_failure(format!("Subscription '{}' not found", subscription_id)).await;
    }
}

/// Returns a list of active subscription IDs.
///
/// # Returns
///
/// * `Vec<String>` - List of active subscription IDs
#[flutter_rust_bridge::frb]
pub async fn list_subscriptions() -> Vec<String> {
    let active_map = SUBSCRIPTION_ACTIVE.read().await;
    active_map.iter()
        .filter(|(_, &active)| active)
        .map(|(id, _)| id.clone())
        .collect()
}


/// Sets up a responder to handle requests on a specified subject.
///
/// # Arguments
///
/// * `subject` - The subject to listen for requests on
/// * `responder_id` - A unique identifier for this responder
/// * `handler` - Function that processes requests and returns responses
/// * `on_success` - Callback function called when responder is set up successfully
/// * `on_error` - Callback function called if responder setup fails
#[flutter_rust_bridge::frb]
pub async fn setup_responder(
    subject: String,
    responder_id: String,
    process_request: impl Fn(String) -> DartFnFuture<String>,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_error: impl Fn(String) -> DartFnFuture<()>,
) {
    // Get the client
    let client_guard = NATS_CLIENT.lock().await;
    let client = match &*client_guard {
        Some(client) => client.clone(),
        None => {
            drop(client_guard);
            on_error("Not connected to NATS server".to_string()).await;
            return;
        }
    };
    drop(client_guard);

    // Subscribe to the subject to receive requests
    match client.subscribe(subject.clone()).await {
        Ok(subscriber) => {
            // Store the subscription
            {
                let mut subs = SUBSCRIPTIONS.write().await;
                subs.insert(responder_id.clone(), subscriber);
            }
            {
                let mut active_map = SUBSCRIPTION_ACTIVE.write().await;
                active_map.insert(responder_id.clone(), true);
            }

            // Notify successful setup
            on_success(true).await;

            // Start processing in the current task
            process_requests(
                client,
                responder_id,
                process_request,
                on_error,
            ).await;
        },
        Err(e) => {
            on_error(format!("Failed to subscribe: {}", e)).await;
        }
    }
}

/// Internal function to process requests
async fn process_requests(
    client: Client,
    responder_id: String,
    process_request: impl Fn(String) -> DartFnFuture<String>,
    on_error: impl Fn(String) -> DartFnFuture<()>,
) {
    // Acquire lock for processing
    let _control_lock = SUBSCRIPTION_CONTROL.lock().await;

    loop {
        // Check if still active
        let is_active = {
            let active_map = SUBSCRIPTION_ACTIVE.read().await;
            active_map.get(&responder_id).copied().unwrap_or(false)
        };

        if !is_active {
            break;
        }

        // Try to get the next message
        let maybe_msg = {
            let mut subs = SUBSCRIPTIONS.write().await;
            if let Some(sub) = subs.get_mut(&responder_id) {
                // Try to get the next message with a small timeout
                tokio::time::timeout(
                    Duration::from_millis(100),
                    sub.next()
                ).await.unwrap_or_else(|_| None)
            } else {
                None // Subscription doesn't exist anymore
            }
        };

        // Process the message if we got one
        if let Some(msg) = maybe_msg {
            if let Some(reply_to) = msg.reply {
                // Convert request payload to string
                match String::from_utf8(msg.payload.to_vec()) {
                    Ok(request_payload) => {
                        // Call handler to get response
                        let response = process_request(request_payload).await;

                        // Send response back
                        match client.publish(reply_to, response.into_bytes().into()).await {
                            Ok(_) => {}, // Response sent successfully
                            Err(e) => {
                                on_error(format!("Failed to send response: {}", e)).await;
                            }
                        }
                    },
                    Err(e) => {
                        on_error(format!("Invalid UTF-8 in request: {}", e)).await;
                    }
                }
            }
        } else {
            // No message, check if subscription still exists
            let sub_exists = {
                let subs = SUBSCRIPTIONS.read().await;
                subs.contains_key(&responder_id)
            };

            if !sub_exists {
                break;
            }

            // Small delay to avoid busy-waiting
            tokio::time::sleep(Duration::from_millis(50)).await;
        }
    }

    // Clean up
    {
        let mut subs = SUBSCRIPTIONS.write().await;
        subs.remove(&responder_id);
    }
    {
        let mut active_map = SUBSCRIPTION_ACTIVE.write().await;
        active_map.remove(&responder_id);
    }
}


/// Puts a value in the key-value store.
#[flutter_rust_bridge::frb]
pub async fn kv_put(
    bucket_name: String,
    key: String,
    value: String,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // Get the client
    let client_guard = NATS_CLIENT.lock().await;
    let client = match &*client_guard {
        Some(client) => client.clone(),
        None => {
            drop(client_guard);
            on_failure("Not connected to NATS server".to_string()).await;
            return;
        }
    };
    drop(client_guard);

    // Use simple publish rather than JetStream
    let subject = format!("kv.{}.{}", bucket_name, key);

    // Publish the value
    match client.publish(subject, value.into_bytes().into()).await {
        Ok(_) => {
            on_success(true).await;
        },
        Err(e) => {
            on_failure(format!("Failed to store value: {}", e)).await;
        }
    }
}

/// Gets a value from the key-value store.
#[flutter_rust_bridge::frb]
pub async fn kv_get(
    bucket_name: String,
    key: String,
    on_success: impl Fn(String) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // Get the client
    let client_guard = NATS_CLIENT.lock().await;
    let client = match &*client_guard {
        Some(client) => client.clone(),
        None => {
            drop(client_guard);
            on_failure("Not connected to NATS server".to_string()).await;
            return;
        }
    };
    drop(client_guard);

    // Construct request subject
    let subject = format!("kv.{}.{}", bucket_name, key);

    // Send request with timeout
    let timeout = std::time::Duration::from_millis(2000);

    match tokio::time::timeout(
        timeout,
        client.request(subject, vec![].into()),
    ).await {
        Ok(result) => match result {
            Ok(response) => {
                // Convert response to string
                match String::from_utf8(response.payload.to_vec()) {
                    Ok(value) => {
                        on_success(value).await;
                    },
                    Err(e) => {
                        on_failure(format!("Invalid UTF-8 in response: {}", e)).await;
                    }
                }
            },
            Err(e) => {
                on_failure(format!("Failed to get value: {}", e)).await;
            }
        },
        Err(_) => {
            on_failure("Request timed out".to_string()).await;
        }
    }
}