//! # Helpers for command execution


use super::Error;
use super::{CmdExecutor, Address, PrivateKey, KeyFile};
use std::path::{Path, PathBuf};
use std::io::{self, Read, Write};
use std::fs::File;
use std::str::FromStr;

#[macro_export]
macro_rules! arg_to_opt {
    ( $arg:expr ) => {{
        let str = $arg.parse::<String>()?;
        if str.is_empty() {
            None
        } else {
            Some(str)
        }
    }};
}


macro_rules! arg_to_address {
    ( $arg:expr ) => {{
        let str = $arg.parse::<String>()?;
        Address::from_str(&str)?
    }};
}

impl CmdExecutor {
    ///
    pub fn import_keyfile<P: AsRef<Path>>(&self, path: P) -> Result<(), Error> {
        let mut json = String::new();
        File::open(path).and_then(
            |mut f| f.read_to_string(&mut json),
        )?;

        let kf = KeyFile::decode(json)?;
        self.storage.put(&kf)?;
        //        io::stdout().write_all(
        //            &format!("kf: {:?}\n", kf).into_bytes(),
        //        )?;

        Ok(())
    }

    ///
    pub fn parse_address(&self) -> Result<Address, Error> {
        Ok(arg_to_address!(self.args.arg_address))
    }

    ///
    pub fn parse_from(&self) -> Result<Address, Error> {
        Ok(arg_to_address!(self.args.arg_from))
    }

    ///
    pub fn parse_to(&self) -> Result<Option<Address>, Error> {
        let str = self.args.arg_to.parse::<String>()?;
        let val = if str.is_empty() {
            None
        } else {
            Some(Address::from_str(&str)?)
        };

        Ok(val)
    }

    ///
    pub fn parse_pk(&self) -> Result<PrivateKey, Error> {
        let pk_str = self.args.arg_path.parse::<String>()?;
        let pk = PrivateKey::from_str(&pk_str)?;

        Ok(pk)
    }

    ///
    pub fn parse_path(&self) -> Result<PathBuf, Error> {
        let pk_str = self.args.arg_path.parse::<String>()?;
        let pk = PathBuf::from(&pk_str);

        Ok(pk)
    }

    ///
    ///
    pub fn request_passphrase() -> Result<String, Error> {
        let mut out = io::stdout();
        out.write_all(b"Enter passphrase: \n")?;
        out.flush()?;

        let mut passphrase = String::new();
        io::stdin().read_line(&mut passphrase)?;

        Ok(passphrase)
    }
}
