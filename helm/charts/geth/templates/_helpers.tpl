{{/*
# Default command
*/}}
{{- define "geth.defaultCommand" -}}
- sh
- -ac
- >
{{- if .Values.global.p2pNodePort.enabled }}
  . /env/init-nodeport;
{{- end }}
  exec geth
  --datadir={{ .Values.global.ethereum.execution.dataDir }}
{{- if .Values.global.p2pNodePort.enabled }}
  --nat=extip:$EXTERNAL_IP
  --port=$EXTERNAL_PORT
{{- else }}
  --nat=extip:$(POD_IP)
  --port={{ .Values.global.ethereum.execution.config.ports.p2p_tcp }}
{{- end }}
  --http
  --http.addr=0.0.0.0
  --http.port={{ .Values.global.ethereum.execution.config.ports.http_rpc  }}
  --http.vhosts=*
  --http.corsdomain=*
  --ws
  --ws.addr=0.0.0.0
  --ws.port={{ .Values.global.ethereum.execution.config.ports.ws_rpc  }}
  --ws.origins=*
  --metrics
  --metrics.addr=0.0.0.0
  --metrics.port={{ .Values.global.ethereum.execution.config.ports.metrics  }}
{{- range .Values.extraArgs }}
  {{ . }}
{{- end }}
{{- end }}

{{/*
# Sync-status check command. Can be used to check when the sync is complete.
*/}}
{{- define "geth.sync-status-check-command" -}}
curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' -H 'Content-Type: application/json' -H 'Accept: application/json' $POD_IP:8545 | jq  -e -r 'has("result")'
{{- end }}