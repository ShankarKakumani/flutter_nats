use async_nats::{self, Client};
use flutter_rust_bridge::DartFnFuture;
use std::time::Duration;
use anyhow::Result;
use std::sync::Arc;
use once_cell::sync::Lazy;
use tokio::sync::RwLock;
use std::collections::HashMap;
use tokio_stream::StreamExt;

/// Multiple clients support for NATS
type ClientId = String;
type SubscriptionId = String;

// A thread-safe map of client IDs to NATS clients
static NATS_CLIENTS: Lazy<Arc<RwLock<HashMap<ClientId, Client>>>> = Lazy::new(|| {
    Arc::new(RwLock::new(HashMap::new()))
});

// Store JetStream Key-Value contexts per client
static KV_STORES: Lazy<Arc<RwLock<HashMap<(ClientId, String), async_nats::jetstream::kv::Store>>>> = Lazy::new(|| {
    Arc::new(RwLock::new(HashMap::new()))
});

// Store active subscriptions per client
static SUBSCRIPTIONS: Lazy<Arc<RwLock<HashMap<(ClientId, SubscriptionId), async_nats::Subscriber>>>> = Lazy::new(|| {
    Arc::new(RwLock::new(HashMap::new()))
});

// Store a flag for each subscription indicating if it should continue
static SUBSCRIPTION_ACTIVE: Lazy<Arc<RwLock<HashMap<(ClientId, SubscriptionId), bool>>>> = Lazy::new(|| {
    Arc::new(RwLock::new(HashMap::new()))
});

/// Initializes flutter_rust_bridge's default utilities.
#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

/// Helper function to get a client by ID with proper error handling
async fn get_client(client_id: &str) -> Result<Client, String> {
    let clients = NATS_CLIENTS.read().await;
    clients.get(client_id)
        .cloned()
        .ok_or_else(|| format!("Client with ID '{}' not found", client_id))
}

/// Connects to a NATS server with the specified client ID and calls appropriate callback based on result.
#[flutter_rust_bridge::frb]
pub async fn connect_to_nats(
    client_id: String,
    end_point: String,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // Check if this client ID already exists
    {
        let clients = NATS_CLIENTS.read().await;
        if clients.contains_key(&client_id) {
            drop(clients);
            on_failure(format!("Client with ID '{}' already exists", client_id)).await;
            return;
        }
    }

    // Connect to the NATS server
    match async_nats::connect(end_point).await {
        Ok(client) => {
            // Store the new client
            {
                let mut clients = NATS_CLIENTS.write().await;
                clients.insert(client_id, client);
            }
            on_success(true).await;
        }
        Err(e) => {
            on_failure(e.to_string()).await;
        }
    }
}

/// Helper function to clean up all subscriptions for a client
async fn cleanup_client_subscriptions(client_id: &str) {
    // First, mark all subscriptions for this client as inactive
    {
        let mut active_map = SUBSCRIPTION_ACTIVE.write().await;
        let client_subs: Vec<(ClientId, SubscriptionId)> = active_map.keys()
            .filter(|(cid, _)| cid == client_id)
            .cloned()
            .collect();

        for key in client_subs {
            if let Some(active) = active_map.get_mut(&key) {
                *active = false;
            }
        }
    }

    // Wait a bit to allow subscription tasks to clean up
    tokio::time::sleep(Duration::from_millis(200)).await;

    // Clear all subscriptions for this client
    {
        let mut subs = SUBSCRIPTIONS.write().await;
        subs.retain(|(cid, _), _| cid != client_id);
    }

    // Clear active flags for this client
    {
        let mut active_map = SUBSCRIPTION_ACTIVE.write().await;
        active_map.retain(|(cid, _), _| cid != client_id);
    }

    // Clean up KV stores for this client
    {
        let mut kv_stores = KV_STORES.write().await;
        kv_stores.retain(|(cid, _), _| cid != client_id);
    }
}

/// Disconnects a specific client from the NATS server.
#[flutter_rust_bridge::frb]
pub async fn disconnect_from_nats(
    client_id: String,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // Clean up all subscriptions first
    cleanup_client_subscriptions(&client_id).await;

    // Disconnect the client
    let mut clients = NATS_CLIENTS.write().await;
    if let Some(client) = clients.remove(&client_id) {
        // Drop the client to close the connection
        drop(client);
        drop(clients);
        on_success(true).await;
    } else {
        drop(clients);
        on_failure(format!("Client with ID '{}' not found", client_id)).await;
    }
}

/// Sends a request to NATS server using the specified client and returns the response.
#[flutter_rust_bridge::frb]
pub async fn send_request(
    client_id: String,
    subject: String,
    payload: String,
    timeout_ms: u64,
) -> Result<String, String> {
    // Get the client
    let client = get_client(&client_id).await?;

    // Create payload as bytes
    let payload_bytes = payload.into_bytes();
    let timeout = Duration::from_millis(timeout_ms);

    // Send request with timeout
    let response = tokio::time::timeout(
        timeout,
        client.request(subject, payload_bytes.into()),
    )
        .await
        .map_err(|_| "Request timed out".to_string())?
        .map_err(|e| e.to_string())?;

    // Convert response payload to string
    String::from_utf8(response.payload.to_vec())
        .map_err(|e| format!("Invalid UTF-8 in response: {}", e))
}

/// Sends a request to NATS server using the specified client and handles response via callbacks.
#[flutter_rust_bridge::frb]
pub async fn _send_request_with_callbacks(
    client_id: String,
    subject: String,
    payload: String,
    timeout_ms: u64,
    on_success: impl Fn(String) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // Use the send_request function and handle its result with callbacks
    match send_request(client_id, subject, payload, timeout_ms).await {
        Ok(response) => {
            on_success(response).await;
        }
        Err(error) => {
            on_failure(error).await;
        }
    }
}

/// Publishes a message to the specified subject using the specified client.
#[flutter_rust_bridge::frb]
pub async fn publish(
    client_id: String,
    subject: String,
    payload: String,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // Get the client
    match get_client(&client_id).await {
        Ok(client) => {
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
        },
        Err(e) => {
            on_failure(e).await;
        }
    }
}

/// Sets up a responder to handle requests on a specified subject using the specified client.
#[flutter_rust_bridge::frb]
pub async fn setup_responder(
    client_id: String,
    subject: String,
    responder_id: String,
    process_request: impl Fn(String) -> DartFnFuture<String> + Send + 'static,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_error: impl Fn(String) -> DartFnFuture<()> + Send + 'static,
) {
    // Get the client
    let client = match get_client(&client_id).await {
        Ok(client) => client,
        Err(e) => {
            on_error(e).await;
            return;
        }
    };

    // Create a unique key for this subscription
    let sub_key = (client_id.clone(), responder_id.clone());

    // Check if this responder already exists
    {
        let subs = SUBSCRIPTIONS.read().await;
        if subs.contains_key(&sub_key) {
            drop(subs);
            on_error(format!("Responder '{}' for client '{}' already exists", responder_id, client_id)).await;
            return;
        }
    }

    // Subscribe to the subject to receive requests
    match client.subscribe(subject.clone()).await {
        Ok(subscriber) => {
            // Store the subscription
            {
                let mut subs = SUBSCRIPTIONS.write().await;
                subs.insert(sub_key.clone(), subscriber);
            }
            {
                let mut active_map = SUBSCRIPTION_ACTIVE.write().await;
                active_map.insert(sub_key.clone(), true);
            }

            // Notify successful setup
            on_success(true).await;

            // Spawn a task to handle this responder
            let sub_key_clone = sub_key.clone();
            tokio::spawn(async move {
                process_responder_requests(
                    client,
                    sub_key_clone,
                    process_request,
                    on_error,
                ).await;
            });
        },
        Err(e) => {
            on_error(format!("Failed to subscribe: {}", e)).await;
        }
    }
}

/// Helper function to safely get the next message from a subscription
async fn get_next_message(sub_key: &(ClientId, SubscriptionId)) -> Option<async_nats::Message> {
    let mut subs = SUBSCRIPTIONS.write().await;
    if let Some(sub) = subs.get_mut(sub_key) {
        // Try to get the next message with a small timeout
        tokio::time::timeout(
            Duration::from_millis(100),
            sub.next()
        ).await.unwrap_or_else(|_| None)
    } else {
        None // Subscription doesn't exist anymore
    }
}

/// Helper function to check if a subscription is active
async fn is_subscription_active(sub_key: &(ClientId, SubscriptionId)) -> bool {
    let active_map = SUBSCRIPTION_ACTIVE.read().await;
    active_map.get(sub_key).copied().unwrap_or(false)
}

/// Helper function to check if a subscription exists
async fn subscription_exists(sub_key: &(ClientId, SubscriptionId)) -> bool {
    let subs = SUBSCRIPTIONS.read().await;
    subs.contains_key(sub_key)
}

/// Internal function to process responder requests
async fn process_responder_requests(
    client: Client,
    sub_key: (ClientId, SubscriptionId),
    process_request: impl Fn(String) -> DartFnFuture<String>,
    on_error: impl Fn(String) -> DartFnFuture<()>,
) {
    loop {
        // Check if still active
        if !is_subscription_active(&sub_key).await {
            break;
        }

        // Try to get the next message
        let maybe_msg = get_next_message(&sub_key).await;

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
            if !subscription_exists(&sub_key).await {
                break;
            }

            // Small delay to avoid busy-waiting
            tokio::time::sleep(Duration::from_millis(50)).await;
        }
    }

    cleanup_subscription(&sub_key).await;
}

/// Helper function to clean up a subscription
async fn cleanup_subscription(sub_key: &(ClientId, SubscriptionId)) {
    // Clean up
    {
        let mut subs = SUBSCRIPTIONS.write().await;
        subs.remove(sub_key);
    }
    {
        let mut active_map = SUBSCRIPTION_ACTIVE.write().await;
        active_map.remove(sub_key);
    }
}

/// Subscribes to a subject and receives messages via a callback using the specified client.
#[flutter_rust_bridge::frb]
pub async fn subscribe(
    client_id: String,
    subject: String,
    subscription_id: String,
    max_messages: u32,
    on_message: impl Fn(String, String) -> DartFnFuture<()> + Send + 'static,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_error: impl Fn(String) -> DartFnFuture<()> + Send + 'static,
    on_done: impl Fn() -> DartFnFuture<()> + Send + 'static,
) {
    // Get the client
    let client = match get_client(&client_id).await {
        Ok(client) => client,
        Err(e) => {
            on_error(e).await;
            return;
        }
    };

    // Create a unique key for this subscription
    let sub_key = (client_id.clone(), subscription_id.clone());

    // Check if we already have this subscription
    {
        let subs = SUBSCRIPTIONS.read().await;
        if subs.contains_key(&sub_key) {
            drop(subs);
            on_error(format!("Subscription '{}' for client '{}' already exists", subscription_id, client_id)).await;
            return;
        }
    }

    // Create the subscription
    match client.subscribe(subject.clone()).await {
        Ok(subscriber) => {
            // Store the subscription and mark it as active
            {
                let mut subs = SUBSCRIPTIONS.write().await;
                subs.insert(sub_key.clone(), subscriber);
            }
            {
                let mut active_map = SUBSCRIPTION_ACTIVE.write().await;
                active_map.insert(sub_key.clone(), true);
            }

            // Notify successful subscription
            on_success(true).await;

            // Spawn a task to handle this subscription
            let subject_clone = subject.clone();
            let sub_key_clone = sub_key.clone();

            tokio::spawn(async move {
                process_subscription_messages(
                    subject_clone,
                    sub_key_clone,
                    max_messages,
                    on_message,
                    on_error,
                    on_done,
                ).await;
            });
        },
        Err(e) => {
            on_error(format!("Failed to subscribe: {}", e)).await;
        }
    }
}

/// Internal function to process subscription messages
async fn process_subscription_messages(
    subject: String,
    sub_key: (ClientId, SubscriptionId),
    max_messages: u32,
    on_message: impl Fn(String, String) -> DartFnFuture<()>,
    on_error: impl Fn(String) -> DartFnFuture<()>,
    on_done: impl Fn() -> DartFnFuture<()>,
) {
    let mut message_count = 0;
    let unlimited = max_messages == 0;

    loop {
        // Check if we should continue (subscription is active)
        if !is_subscription_active(&sub_key).await {
            break;
        }

        // Check message count limit
        if !unlimited && message_count >= max_messages {
            break;
        }

        // Get the next message
        let maybe_msg = get_next_message(&sub_key).await;

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
                if !subscription_exists(&sub_key).await {
                    break;
                }

                // Small delay to avoid busy-waiting
                tokio::time::sleep(Duration::from_millis(50)).await;
            }
        }
    }

    // Subscription ended, clean up
    cleanup_subscription(&sub_key).await;

    // Notify completion
    on_done().await;
}

/// Unsubscribes from a subject for the specified client.
#[flutter_rust_bridge::frb]
pub async fn unsubscribe(
    client_id: String,
    subscription_id: String,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // Create the unique key for this subscription
    let sub_key = (client_id.clone(), subscription_id.clone());

    // Mark the subscription as inactive
    let exists = {
        let mut active_map = SUBSCRIPTION_ACTIVE.write().await;
        if let Some(active) = active_map.get_mut(&sub_key) {
            *active = false;
            true
        } else {
            false
        }
    };

    if exists {
        on_success(true).await;
    } else {
        on_failure(format!("Subscription '{}' for client '{}' not found", subscription_id, client_id)).await;
    }
}

/// Returns a list of active subscription IDs for the specified client.
#[flutter_rust_bridge::frb]
pub async fn list_subscriptions(client_id: String) -> Vec<String> {
    let active_map = SUBSCRIPTION_ACTIVE.read().await;
    active_map.iter()
        .filter(|((cid, _), active)| cid == &client_id && **active)
        .map(|((_, id), _)| id.clone())
        .collect()
}

/// Returns a list of connected client IDs.
#[flutter_rust_bridge::frb]
pub async fn list_clients() -> Vec<String> {
    let clients = NATS_CLIENTS.read().await;
    clients.keys().cloned().collect()
}

/// Helper function to get a JetStream context for a client
async fn get_jetstream(client_id: &str) -> Result<(Client, async_nats::jetstream::Context), String> {
    let client = get_client(client_id).await?;
    let jetstream = async_nats::jetstream::new(client.clone());
    Ok((client, jetstream))
}

/// Helper function to get a KV store with error handling via callback
async fn get_kv_store_with_callback<F>(
    client_id: &str,
    bucket_name: &str,
    on_failure: &F
) -> Option<async_nats::jetstream::kv::Store>
where
    F: Fn(String) -> DartFnFuture<()>,
{
    // Get the client and JetStream context
    let (_, jetstream) = match get_jetstream(client_id).await {
        Ok(result) => result,
        Err(e) => {
            on_failure(e).await;
            return None;
        }
    };

    // Get or create the KV store
    match get_or_create_kv_store(&jetstream, client_id, bucket_name).await {
        Ok(store) => Some(store),
        Err(e) => {
            on_failure(format!("Failed to access KV bucket: {}", e)).await;
            None
        }
    }
}

/// Puts a value in the key-value store using JetStream for the specified client.
#[flutter_rust_bridge::frb]
pub async fn kv_put(
    client_id: String,
    bucket_name: String,
    key: String,
    value: String,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // Get the KV store with error handling
    let store = match get_kv_store_with_callback(&client_id, &bucket_name, &on_failure).await {
        Some(store) => store,
        None => return,
    };

    // Put the value
    let bytes_value = bytes::Bytes::from(value.into_bytes());
    match store.put(&key, bytes_value).await {
        Ok(_) => {
            on_success(true).await;
        },
        Err(e) => {
            on_failure(format!("Failed to store value: {}", e)).await;
        }
    }
}

/// Gets a value from the key-value store using JetStream for the specified client.
#[flutter_rust_bridge::frb]
pub async fn kv_get(
    client_id: String,
    bucket_name: String,
    key: String,
    on_success: impl Fn(String) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // Get the KV store with error handling
    let store = match get_kv_store_with_callback(&client_id, &bucket_name, &on_failure).await {
        Some(store) => store,
        None => return,
    };

    // Get the value
    match store.get(&key).await {
        Ok(Some(entry)) => {
            // Convert entry to string
            match String::from_utf8(entry.to_vec()) {
                Ok(value) => {
                    on_success(value).await;
                },
                Err(e) => {
                    on_failure(format!("Invalid UTF-8 in value: {}", e)).await;
                }
            }
        },
        Ok(None) => {
            on_failure(format!("Key '{}' not found", key)).await;
        },
        Err(e) => {
            on_failure(format!("Failed to get value: {}", e)).await;
        }
    }
}

/// Deletes a key from the key-value store using JetStream for the specified client.
#[flutter_rust_bridge::frb]
pub async fn kv_delete(
    client_id: String,
    bucket_name: String,
    key: String,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // Get the KV store with error handling
    let store = match get_kv_store_with_callback(&client_id, &bucket_name, &on_failure).await {
        Some(store) => store,
        None => return,
    };

    // Delete the key
    match store.delete(&key).await {
        Ok(_) => {
            on_success(true).await;
        },
        Err(e) => {
            on_failure(format!("Failed to delete key: {}", e)).await;
        }
    }
}

/// Helper function to get or create a KV store for a specific client.
async fn get_or_create_kv_store(
    jetstream: &async_nats::jetstream::Context,
    client_id: &str,
    bucket_name: &str,
) -> Result<async_nats::jetstream::kv::Store, String> {
    // Create a composite key for storing in the cache
    let cache_key = (client_id.to_string(), bucket_name.to_string());

    // Check if we have this store cached
    {
        let stores = KV_STORES.read().await;
        if let Some(store) = stores.get(&cache_key) {
            return Ok(store.clone());
        }
    }

    // Not cached, try to get from server
    match jetstream.get_key_value(bucket_name).await {
        Ok(store) => {
            // Cache the store
            {
                let mut stores = KV_STORES.write().await;
                stores.insert(cache_key, store.clone());
            }
            Ok(store)
        },
        Err(e) => {
            // If error is "stream not found", try to create it
            if e.to_string().contains("stream not found") {
                // Create KV bucket configuration
                let config = async_nats::jetstream::kv::Config {
                    bucket: bucket_name.to_string(),
                    description: format!("KV Store for {} (client {})", bucket_name, client_id),
                    max_value_size: 1024 * 1024, // 1MB max value size
                    history: 5,                  // Keep 5 revisions
                    ..Default::default()
                };

                // Create the bucket
                match jetstream.create_key_value(config).await {
                    Ok(store) => {
                        // Cache the store
                        {
                            let mut stores = KV_STORES.write().await;
                            stores.insert(cache_key, store.clone());
                        }
                        Ok(store)
                    },
                    Err(create_err) => {
                        Err(format!("Failed to create KV bucket: {}", create_err))
                    }
                }
            } else {
                Err(format!("Failed to access KV bucket: {}", e))
            }
        }
    }
}