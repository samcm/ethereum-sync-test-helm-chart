{{/*
# Beacon command
*/}}
{{- define "lighthouse.beaconCommand" -}}
{{- if .Values.global.p2pNodePort.enabled }}
  . /env/init-nodeport; \
{{- end }}
  lighthouse \
  beacon_node \
  --datadir={{ .Values.global.ethereum.consensus.dataDir }} \
  --disable-upnp \
  --disable-enr-auto-update \
{{- if .Values.global.p2pNodePort.enabled }}
  --enr-address=$EXTERNAL_IP \
  --enr-tcp-port=$EXTERNAL_CONSENSUS_PORT \
  --enr-udp-port=$EXTERNAL_CONSENSUS_PORT \
{{- else }}
  --enr-address=$(POD_IP) \
  --enr-tcp-port={{ .Values.global.ethereum.consensus.config.ports.p2p_tcp }} \
  --enr-udp-port={{ .Values.global.ethereum.consensus.config.ports.p2p_udp }} \
{{- end }}
  --listen-address=0.0.0.0 \
  --port={{ .Values.global.ethereum.consensus.config.ports.p2p_tcp }} \
  --discovery-port={{ .Values.global.ethereum.consensus.config.ports.p2p_tcp }} \
  --http \
  --http-address=0.0.0.0 \
  --http-port={{ .Values.global.ethereum.consensus.config.ports.http_api }} \
  --metrics \
  --metrics-address=0.0.0.0 \
  --metrics-port={{ .Values.global.ethereum.consensus.config.ports.metrics }} \
  --eth1 \
  --execution-endpoints="http://${POD_IP}:{{ .Values.global.ethereum.execution.config.ports.engine_api }}" \
  --eth1-endpoints="http://${POD_IP}:{{ .Values.global.ethereum.execution.config.ports.http_rpc }}" \
  --jwt-secrets="/data/jwtsecret" \
{{- range .Values.extraArgs }}
  {{ . }}
{{- end }}
{{- $networkArgs := ((get (get .Values.global.networkConfigs .Values.global.ethereum.network) "consensus").args).lighthouse }}
{{- range $networkArgs }}
  {{ . }}
{{- end }}
{{- end }}
