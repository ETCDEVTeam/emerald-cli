//! # Send JSON encoded HTTP requests

use hyper::Url;
use hyper::client::IntoUrl;
use jsonrpc_core::Params;
use reqwest::Client;
use serde_json::Value;
use ctrl::Error;


lazy_static! {
    static ref CLIENT: Client = Client::new().expect("Expect to create an HTTP client");
}


/// RPC methods
#[derive(Clone, Copy, Debug, Hash, PartialEq, Eq)]
pub enum ClientMethod {
    /// [eth_gasPrice](https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_gasprice)
    EthGasPrice,

    /// [eth_getTransactionCount](
    /// https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_gettransactioncount)
    EthGetTxCount,

    /// [eth_getTransactionByHash](
    /// https://github.com/ethereumproject/wiki/wiki/JSON-RPC#eth_gettransactionbyhash)
    EthGetTxByHash,

    /// [eth_sendRawTransaction](
    /// https://github.com/paritytech/parity/wiki/JSONRPC-eth-module#eth_sendrawtransaction)
    EthSendRawTransaction,
}

/// RPC method's parameters
#[derive(Clone, Debug, PartialEq)]
pub struct MethodParams<'a>(pub ClientMethod, pub &'a Params);

pub struct Connector {
    pub url: Url,
}

impl Connector {
    pub fn new<U: IntoUrl>(url: U) -> Connector {
        Connector { url: url.into_url().expect("Expect to encode request url") }
    }

    /// Send and JSON RPC HTTP post request
    pub fn send_post(&self, params: &MethodParams) -> Result<Value, Error> {
        let mut res = CLIENT.post(self.url.clone()).json(params).send()?;
        let json: Value = res.json()?;

        Ok(json["result"].clone())
    }
}
