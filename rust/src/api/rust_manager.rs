use flutter_rust_bridge::DartFnFuture;
use std::time::Duration;
use tokio::time::sleep;

pub trait ConnectionCallback {
    fn on_success(&self);
    fn on_failure(&self, error: String);
    fn f(&self, a: String) -> i32;
}

/// Initializes flutter_rust_bridge's default utilities.
#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub async fn fun_with_return_callback(dart_callback: impl Fn(String) -> DartFnFuture<String>) {
    sleep(Duration::from_secs(10)).await;
    let result = dart_callback("Tom".to_owned()).await;
    println!("Received from dart_callback: {}", result);
}

pub async fn fun_with_only_callback(dart_callback: impl Fn(String) -> DartFnFuture<bool>) {
    sleep(Duration::from_secs(10)).await;
    dart_callback("Tom".to_owned()).await; // Will get `Hello, Tom!`
}

pub async fn connect_to_nats(
    end_point: String,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // Attempt to connect to NATS.
    let result = async_nats::connect(end_point).await;

    // Check if the connection resulted in an error.
    if let Err(e) = result {
        on_failure(e.to_string()).await;
        return;
    }

    // If the connection was successful, unwrap safely and call on_success.
    let _client = result.unwrap();
    on_success(true).await;
}
