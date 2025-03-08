use async_nats;
use futures_util::StreamExt;
use once_cell::sync::Lazy;
use std::sync::Mutex;
use tokio::runtime::Runtime;
use tokio::task::JoinHandle;

// Global runtime to keep background tasks alive.
static GLOBAL_RT: Lazy<Mutex<Option<Runtime>>> = Lazy::new(|| Mutex::new(None));
// Global NATS client, so we only connect once.
static GLOBAL_CLIENT: Lazy<Mutex<Option<async_nats::Client>>> = Lazy::new(|| Mutex::new(None));
// Global responder task handle.
static GLOBAL_RESPONDER: Lazy<Mutex<Option<JoinHandle<()>>>> =
    Lazy::new(|| Mutex::new(None));

/// Ensures that the global Tokio runtime is initialized.
fn ensure_global_rt() -> Result<(), String> {
    let mut rt_guard = GLOBAL_RT.lock().unwrap();
    if rt_guard.is_none() {
        *rt_guard =
            Some(Runtime::new().map_err(|e| format!("Failed to create Tokio runtime: {}", e))?);
    }
    Ok(())
}

/// Returns the global NATS client. If not already connected, it creates and stores it.
fn get_client(nats_url: &str) -> Result<async_nats::Client, String> {
    ensure_global_rt()?;
    {
        let client_guard = GLOBAL_CLIENT.lock().unwrap();
        if let Some(client) = &*client_guard {
            return Ok(client.clone());
        }
    }
    let rt_guard = GLOBAL_RT.lock().unwrap();
    let rt = rt_guard.as_ref().ok_or("Runtime not available".to_owned())?;
    let client = rt.block_on(async {
        async_nats::connect(nats_url)
            .await
            .map_err(|e| format!("Failed to connect: {}", e))
    })?;
    let mut client_guard = GLOBAL_CLIENT.lock().unwrap();
    *client_guard = Some(client.clone());
    Ok(client)
}

/// Connects to the given NATS server and returns a status message.
/// (This will create a persistent connection.)
#[flutter_rust_bridge::frb(sync)]
#[flutter_rust_bridge::frb(mirror())]
pub fn connect_sync(nats_url: String) -> Result<String, String> {
    let _client = get_client(&nats_url)?;
    Ok("Connected to NATS successfully".to_owned())
}

/// Disconnects from NATS by dropping the global client.
#[flutter_rust_bridge::frb(sync)]
#[flutter_rust_bridge::frb(mirror())]
pub fn disconnect_sync() -> Result<String, String> {
    let mut client_guard = GLOBAL_CLIENT.lock().unwrap();
    if client_guard.is_some() {
        *client_guard = None;
        Ok("Disconnected from NATS".to_owned())
    } else {
        Ok("No active connection".to_owned())
    }
}

/// Sends a request on the specified subject with the provided message,
/// waits for a response, and returns the response as a UTF-8 string.
#[flutter_rust_bridge::frb(sync)]
#[flutter_rust_bridge::frb(mirror())]
pub fn send_request_sync(
    nats_url: String,
    subject: String,
    message: String,
) -> Result<String, String> {
    let client = get_client(&nats_url)?;
    let rt_guard = GLOBAL_RT.lock().unwrap();
    let rt = rt_guard.as_ref().ok_or("Runtime not available".to_owned())?;
    rt.block_on(async {
        let response = client
            .request(subject, message.into())
            .await
            .map_err(|e| format!("Request failed: {}", e))?;
        String::from_utf8(response.payload.to_vec())
            .map_err(|e| format!("Invalid UTF-8 response: {}", e))
    })
}

/// Starts a responder that listens on the given subject and replies with the provided reply message.
/// The responder runs as a background task.
#[flutter_rust_bridge::frb(sync)]
#[flutter_rust_bridge::frb(mirror())]
pub fn start_responder_sync(
    nats_url: String,
    subject: String,
    reply_message: String,
) -> Result<String, String> {
    let client = get_client(&nats_url)?;
    let rt_guard = GLOBAL_RT.lock().unwrap();
    let rt = rt_guard.as_ref().ok_or("Runtime not available".to_owned())?;
    let responder_handle = rt.spawn({
        let client_clone = client.clone();
        let subject = subject.clone();
        let reply_message = reply_message.clone();
        async move {
            match client_clone.subscribe(subject).await {
                Ok(mut subscription) => {
                    while let Some(msg) = subscription.next().await {
                        if let Some(reply_to) = msg.reply {
                            let _ = client_clone
                                .publish(reply_to, reply_message.clone().into())
                                .await;
                        }
                    }
                }
                Err(e) => eprintln!("Failed to subscribe: {}", e),
            }
        }
    });
    let mut responder_guard = GLOBAL_RESPONDER.lock().unwrap();
    *responder_guard = Some(responder_handle);
    Ok("Responder started".to_owned())
}

/// Stops the responder by aborting its background task.
#[flutter_rust_bridge::frb(sync)]
#[flutter_rust_bridge::frb(mirror())]
pub fn stop_responder_sync() -> Result<String, String> {
    let mut responder_guard = GLOBAL_RESPONDER.lock().unwrap();
    if let Some(handle) = responder_guard.take() {
        handle.abort();
        Ok("Responder stopped".to_owned())
    } else {
        Ok("Responder was not running".to_owned())
    }
}

/// Initializes flutter_rust_bridge's default utilities.
#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
