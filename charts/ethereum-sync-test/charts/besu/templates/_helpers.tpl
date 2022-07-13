{{/*
# Beacon command
*/}}
{{- define "besu.defaultCommand" -}}
{{- if .Values.global.p2pNodePort.enabled }}
  . /env/init-nodeport; \
{{- end }}
  besu \
  --data-path={{ .Values.global.ethereum.execution.dataDir }} \
  --p2p-enabled=true \
{{- if .Values.global.p2pNodePort.enabled }}
  --p2p-host="$EXTERNAL_IP" \
{{- else }}
  --p2p-host=$(POD_IP) \
{{- end }}
  --p2p-port={{ .Values.global.ethereum.execution.config.ports.p2p_tcp }} \
  --rpc-http-enabled \
  --rpc-http-enabled=true \
  --rpc-http-api=ENGINE,NET,ETH,ADMIN,TXPOOL,WEB3 \
  --rpc-http-host=0.0.0.0 \
  --rpc-http-port={{ .Values.global.ethereum.execution.config.ports.http_rpc }} \
  --rpc-http-cors-origins=* \
  --rpc-ws-enabled \
  --rpc-ws-host=0.0.0.0 \
  --rpc-ws-port={{ .Values.global.ethereum.execution.config.ports.ws_rpc }} \
  --host-allowlist=* \
  --metrics-enabled \
  --metrics-host=0.0.0.0 \
  --metrics-port={{ .Values.global.ethereum.execution.config.ports.metrics }} \
  --engine-jwt-enabled \
  --engine-jwt-secret=/data/jwtsecret \
  {{- if ne (.Values.global.ethereum.execution.config.ports.engine_api) 85222251.0 }}
  --engine-rpc-port={{ .Values.global.ethereum.execution.config.ports.engine_api }} \
  {{- end }}
  --engine-host-allowlist="*" \
  --sync-mode=FAST \
  --fast-sync-min-peers=1 \
  --data-storage-format="BONSAI" \
{{- range .Values.extraArgs }}
  {{ . }}
{{- end }}
{{- $networkArgs := ((get (get .Values.global.networkConfigs .Values.global.ethereum.network) "execution").args).besu }}
{{- range $networkArgs }}
  {{ . }}
{{- end }}
{{- end }}
