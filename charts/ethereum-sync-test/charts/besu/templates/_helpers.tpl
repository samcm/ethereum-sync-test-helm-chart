{{/*
# Beacon command
*/}}
{{- define "besu.defaultCommand" -}}
- sh
- -ac
- >
{{- if .Values.global.p2pNodePort.enabled }}
  . /env/init-nodeport;
{{- end }}
  trap 'exit 0' INT TERM;
  besu
  --data-path={{ .Values.global.ethereum.execution.dataDir }}
  --p2p-enabled=true
{{- if .Values.global.p2pNodePort.enabled }}
  --p2p-host=$EXTERNAL_IP
  --p2p-port=$EXTERNAL_EXECUTION_PORT
{{- else }}
  --p2p-host=$(POD_IP)
  --p2p-port={{ .Values.global.ethereum.execution.config.ports.p2p_tcp }}
{{- end }}
  --rpc-http-enabled
  --rpc-http-enabled=true
  --rpc-http-api=ENGINE,NET,ETH,ADMIN
  --rpc-http-host=0.0.0.0
  --rpc-http-port={{ .Values.global.ethereum.execution.config.ports.http_rpc }}
  --rpc-http-cors-origins=*
  --rpc-ws-enabled
  --rpc-ws-host=0.0.0.0
  --rpc-ws-port={{ .Values.global.ethereum.execution.config.ports.ws_rpc }}
  --host-allowlist=*
  --metrics-enabled
  --metrics-host=0.0.0.0
  --metrics-port={{ .Values.global.ethereum.execution.config.ports.metrics }}
  --engine-jwt-enabled
  --engine-jwt-secret=/data/jwtsecret
  {{- if ne (.Values.global.ethereum.execution.config.ports.engine_api) 85222251.0 }}
  --engine-rpc-http-port={{ .Values.global.ethereum.execution.config.ports.engine_api }}
  {{- end }}
  --engine-rpc-ws-port={{ .Values.global.ethereum.execution.config.ports.engine_ws }}
  --engine-host-allowlist="*"
  --sync-mode=FAST
  --fast-sync-min-peers=1
  --data-storage-format="BONSAI"
{{- $networkArgs := ((get (get .Values.global.networkConfigs .Values.global.ethereum.network) "execution").args).besu }}
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
{{- define "besu.sync-status-check-command" -}}
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