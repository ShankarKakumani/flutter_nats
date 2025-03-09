use std::time::Duration;
use flutter_rust_bridge::DartFnFuture;
use tokio::time::sleep;

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

pub async fn rust_function(dart_callback: impl Fn(String) -> DartFnFuture<String>) {
    dart_callback("Tom".to_owned()).await; // Will get `Hello, Tom!`
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

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
