{{/*
# Default command
*/}}
{{- define "erigon.defaultCommand" -}}
{{- if .Values.global.p2pNodePort.enabled }}
  . /env/init-nodeport; \
{{- end }}
  erigon \
  --datadir="{{ .Values.global.ethereum.execution.dataDir }}" \
{{- if .Values.global.p2pNodePort.enabled }}
  --nat extip:$EXTERNAL_IP \
  --port=$EXTERNAL_EXECUTION_PORT \
{{- else }}
  --nat=extip:$(POD_IP) \
  --port={{ .Values.global.ethereum.execution.config.ports.p2p_tcp }} \
{{- end }}
  --metrics \
  --metrics.addr=0.0.0.0 \
  --metrics.port={{ .Values.global.ethereum.execution.config.ports.metrics  }} \
  --allow-insecure-unlock \
  --prune=htc \
  --http \
  --http.api "admin,engine,net,eth,web3" \
  --http.port={{ .Values.global.ethereum.execution.config.ports.http_rpc }} \
  --http.addr 0.0.0.0 \
  --http.corsdomain "*" \
  --private.api.addr=0.0.0.0:8088 \
  --authrpc.jwtsecret="/data/jwtsecret" \
  --verbosity=3 \
  --batchSize=16m \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port={{ .Values.global.ethereum.execution.config.ports.engine_api }} \
{{- range .Values.extraArgs }}
  {{ . }}
{{- end }}
{{- $networkArgs := ((get (get .Values.global.networkConfigs .Values.global.ethereum.network) "execution").args).erigon }}
{{- range $networkArgs }}
  {{ . }}
{{- end }}
{{- end }}
