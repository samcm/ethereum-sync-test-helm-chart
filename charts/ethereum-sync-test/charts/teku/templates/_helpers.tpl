{{/*
# Beacon command
*/}}
{{- define "teku.beaconCommand" -}}
{{- if .Values.global.p2pNodePort.enabled }}
  . /env/init-nodeport; \
{{- end }}
  /opt/teku/bin/teku \
  --log-destination=CONSOLE \
  --data-path={{ .Values.global.ethereum.consensus.dataDir }} \
  --p2p-enabled=true \
{{- if .Values.global.p2pNodePort.enabled }}
  --p2p-advertised-ip=$EXTERNAL_IP \
  --p2p-advertised-port=$EXTERNAL_CONSENSUS_PORT \
{{- else }}
  --p2p-advertised-ip=$(POD_IP) \
  --p2p-advertised-port={{ .Values.global.ethereum.consensus.config.ports.p2p_tcp }} \
{{- end }}
  --rest-api-enabled=true \
  --rest-api-interface=0.0.0.0 \
  --rest-api-host-allowlist=* \
  --rest-api-port={{ .Values.global.ethereum.consensus.config.ports.http_api }} \
  --metrics-enabled=true \
  --metrics-interface=0.0.0.0 \
  --metrics-host-allowlist=* \
  --metrics-port={{ .Values.global.ethereum.consensus.config.ports.metrics }} \
  --ee-jwt-secret-file="/data/jwtsecret" \
  --eth1-endpoints="http://${POD_IP}:{{ .Values.global.ethereum.execution.config.ports.http_rpc }}" \
  --ee-endpoint="http://${POD_IP}:{{ .Values.global.ethereum.execution.config.ports.engine_api }}" \
  --data-storage-mode=PRUNE \
{{- $networkArgs := ((get (get .Values.global.networkConfigs .Values.global.ethereum.network) "consensus").args).teku }}
{{- range $networkArgs }}
  {{ . }}
{{- end }}
{{- range .Values.extraArgs }}
  {{ . }}
{{- end }}
{{- end }}
