// Copyright (c) 2021, Facebook, Inc. and its affiliates
// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0
use crate::primary::PayloadToken;
use config::WorkerId;
use store::Store;
use tokio::task::JoinHandle;
use tracing::info;
use types::{metered_channel::Receiver, BatchDigest};

#[cfg(test)]
#[path = "tests/payload_receiver_tests.rs"]
mod payload_receiver_tests;

/// Receives batches' digests of other authorities. These are only needed to verify incoming
/// headers (i.e.. make sure we have their payload).
pub struct PayloadReceiver {
    /// The persistent storage.
    store: Store<(BatchDigest, WorkerId), PayloadToken>,
    /// Receives batches' digests from the network.
    rx_workers: Receiver<(BatchDigest, WorkerId)>,
}

impl PayloadReceiver {
    #[must_use]
    pub fn spawn(
        store: Store<(BatchDigest, WorkerId), PayloadToken>,
        rx_workers: Receiver<(BatchDigest, WorkerId)>,
    ) -> JoinHandle<()> {
        tokio::spawn(async move {
            Self { store, rx_workers }.run().await;
        })
    }

    async fn run(&mut self) {
        info!("PayloadReceiver has started successfully.");
        while let Some((digest, worker_id)) = self.rx_workers.recv().await {
            self.store.write((digest, worker_id), 0u8).await;
        }
    }
}
