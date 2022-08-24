{{/*
# Beacon command
*/}}
{{- define "lodestar.beaconCommand" -}}
{{- if .Values.global.p2pNodePort.enabled }}
  . /env/init-nodeport; \
{{- end }}
  node /usr/app/node_modules/.bin/lodestar \
  beacon \
  --dataDir={{ .Values.global.ethereum.consensus.dataDir }} \
  --listenAddress=0.0.0.0 \
  --port={{ .Values.global.ethereum.consensus.config.ports.p2p_tcp }} \
{{- if .Values.global.p2pNodePort.enabled }}
  --enr.ip=$EXTERNAL_IP \
  --enr.tcp=$EXTERNAL_CONSENSUS_PORT \
  --enr.udp=$EXTERNAL_CONSENSUS_PORT \
{{- else }}
  --enr.ip=$(POD_IP) \
  --enr.tcp=$EXTERNAL_CONSENSUS_PORT \
  --enr.udp=$EXTERNAL_CONSENSUS_PORT \
{{- end }}
  --jwt-secret=/data/jwtsecret \
  --rest \
  --rest.address=0.0.0.0 \
  --rest.port={{ .Values.global.ethereum.consensus.config.ports.http_api }} \
  --metrics \
  --metrics.address=0.0.0.0 \
  --metrics.port={{ .Values.global.ethereum.consensus.config.ports.metrics }} \
  --execution.urls="http://${POD_IP}:{{ .Values.global.ethereum.execution.config.ports.engine_api }}" \
  --logLevel={{ .Values.global.ethereum.consensus.logLevel }} \
{{- if .Values.global.ethereum.consensus.checkpointSync.enabled }}
  --weakSubjectivitySyncLatest=true \
  --weakSubjectivityServerUrl={{ .Values.global.ethereum.consensus.checkpointSync.nodeUrl }} \
{{- end }}
{{- range .Values.extraArgs }}
  {{ . }}
{{- end }}
{{- $networkArgs := ((get (get .Values.global.networkConfigs .Values.global.ethereum.network) "consensus").args).lodestar }}
{{- range $networkArgs }}
  {{ . }}
{{- end }}
{{- end }}
