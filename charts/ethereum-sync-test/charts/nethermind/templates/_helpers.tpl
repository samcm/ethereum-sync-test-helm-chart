{{/*
# Beacon command
*/}}
{{- define "nethermind.defaultCommand" -}}
- sh
- -ac
- >
{{- if .Values.global.p2pNodePort.enabled }}
  . /env/init-nodeport;
{{- end }}
  trap 'exit 0' INT TERM;
  /nethermind/Nethermind.Runner
  --datadir={{ .Values.global.ethereum.execution.dataDir }}
  --KeyStore.KeyStoreDirectory={{ .Values.global.ethereum.execution.dataDir }}/keystore
  --Network.LocalIp=$(POD_IP)
{{- if .Values.global.p2pNodePort.enabled }}
  --Network.ExternalIp=$EXTERNAL_IP
  --Network.P2PPort=$EXTERNAL_EXECUTION_PORT
  --Network.DiscoveryPort=$EXTERNAL_EXECUTION_PORT
{{- else }}
  --Network.ExternalIp=$(POD_IP)
  --Network.P2PPort={{ .Values.global.ethereum.execution.config.ports.p2p_tcp }}
  --Network.DiscoveryPort={{ .Values.global.ethereum.execution.config.ports.p2p_tcp }}
{{- end }}
  --JsonRpc.Enabled=true
  --JsonRpc.EnabledModules="net,eth,consensus,subscribe,web3,admin,txpool"
  --JsonRpc.Host=0.0.0.0
  --JsonRpc.Port={{ .Values.global.ethereum.execution.config.ports.http_rpc }}
  --Init.WebSocketsEnabled=true
  --JsonRpc.WebSocketsPort={{ .Values.global.ethereum.execution.config.ports.ws_rpc }}
  --Metrics.Enabled=true
  --Metrics.NodeName=$(POD_NAME)
  --Metrics.ExposePort={{ .Values.global.ethereum.execution.config.ports.metrics }}
  --JsonRpc.AdditionalRpcUrls="o-auth,http://0.0.0.0:{{ .Values.global.ethereum.execution.config.ports.engine_api }}|http;ws|net;eth;subscribe;engine;web3;client"
  --JsonRpc.JwtSecretFile="/data/jwtsecret"
{{- $networkArgs := ((get (get .Values.global.networkConfigs .Values.global.ethereum.network) "execution").args).nethermind }}
{{- range $networkArgs }}
  {{ . }}
{{- end }}
{{- range .Values.extraArgs }}
  {{ . }}
{{- end }}
{{- end }}


{{/*
# Sync-status check command. Can be used to check when the sync is complete.
*/}}
{{- define "nethermind.sync-status-check-command" -}}
#!/bin/sh
currentBlock=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' -H 'Content-Type: application/json' -H 'Accept: application/json' $POD_IP:8545 | jq -e '.result') 2> /dev/null
if [ "$currentBlock" == "0x0" ]; then
  echo "0";
  exit 0;
fi;
syncing=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' -H 'Content-Type: application/json' -H 'Accept: application/json' $POD_IP:8545 | jq -e '.result') 2> /dev/null
if [ "$syncing" == "false" ]; then
  echo "100";
else
  current=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' -H 'Content-Type: application/json' -H 'Accept: application/json' $POD_IP:8545 | jq -e '.result.currentBlock' | xargs printf '%d' || echo 0) 2> /dev/null
  highest=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' -H 'Content-Type: application/json' -H 'Accept: application/json' $POD_IP:8545 | jq -e '.result.highestBlock' | xargs printf '%d' || echo 100000000) 2> /dev/null
  percent=$((($current * 100) / $highest));
  if [[ $percent == 100 ]]; then
    percent=99;
  fi;
  echo -ne "$percent";
fi;
{{- end }}