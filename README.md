# Ethereum Sync Tests Helm Chart
Creates a Kubernetes cronjob to test if a pair of Execution & Consensus clients can sync in a handful of scenarios.

For more info, and test results, check our the [Ethereum Sync Testing repo](https://github.com/samcm/ethereum-sync-testing).



## Getting started
### Add the chart repo
```
helm repo add est https://samcm.github.io/ethereum-sync-test-helm-chart
```

### Install the chart
For configuration, refer to the default values file [here](https://github.com/samcm/ethereum-sync-test-helm-chart/blob/main/charts/ethereum-sync-test/values.yaml). A set of values files can be found in the `values/` folder to easily configure your tests. 

Eg.
```
helm helm upgrade --install eth-sync-test-1 est/ethereum-sync-tests 
-f ./charts/ethereum-sync-test/values/tests/to-head.yaml \
-f ./charts/ethereum-sync-test/values/networks/ropsten.yaml \
-f ./charts/ethereum-sync-test/values/clients/consensus/lodestar.yaml \
-f ./charts/ethereum-sync-test/values/clients/execution/nethermind.yaml
```

> Note: Helm accepts remote URLs as valid values files locations. e.g. helm install ... -f https://raw.githubusercontent.com/samcm/ethereum-sync-test-helm-chart/main/charts/ethereum-sync-test/values/networks/kiln.yaml ...

## Supported tests
- Is Healthy
  - Waits for both the EL and CL to be "healthy".
- Starts Syncing
  - Waits for both the EL and CL to start syncing.
- To Head 
  - The most basic test. Waits for the client pair to sync to the head of the chain.
- Complex test 1
  - Fully syncs EL & CL, stops the EL for < 1 epoch and then restarts the EL. Waits for both to be considered synced.
- Complex test 2
  - Fully syncs EL & CL, stops EL for > 1 epoch and then restarts EL. Waits for both to be considered synced.
- Complex test 3
  - Fully syncs EL, then starts genesis syncing CL. Then stops EL for a few epochs, starts EL and waits for both to be considered synced.

## Supported Networks
- Kiln
- Ropsten

## Supported Clients
Execution:
- Geth
- Nethermind
- Besu
- Erigon

Consensus:
- Lighthouse
- Prysm
- Teku
- Nimbus
- Lodestar

## Built With

* [samcm/sync-test-coordinator](https://github.com/samcm/sync-test-coordinator)
* [samcm/ethereum-metrics-exporter](https://github.com/samcm/ethereum-metrics-exporter)
