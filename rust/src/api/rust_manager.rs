use async_nats;
use flutter_rust_bridge::DartFnFuture;
use once_cell::sync::Lazy;
use std::sync::Mutex;
use tokio::runtime::Runtime;

static GLOBAL_RT: Lazy<Mutex<Option<Runtime>>> = Lazy::new(|| Mutex::new(None));
static GLOBAL_CLIENT: Lazy<Mutex<Option<async_nats::Client>>> = Lazy::new(|| Mutex::new(None));

/// Initializes flutter_rust_bridge's default utilities.
#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub async fn connect_to_nats(
    end_point: String,
    on_success: impl Fn(bool) -> DartFnFuture<()>,
    on_failure: impl Fn(String) -> DartFnFuture<()>,
) {
    // Attempt to connect to NATS.
    let result = async_nats::connect(end_point).await;
    match result {
        Err(e) => {
            on_failure(e.to_string()).await;
        }
        Ok(_) => {
            on_success(true).await;
        }
    }
}

pub fn send_request() {}
