{{/*
# Beacon command
*/}}
{{- define "lodestar.beaconCommand" -}}
{{- if .Values.global.p2pNodePort.enabled }}
  . /env/init-nodeport; \
{{- end }}
  node /usr/app/node_modules/.bin/lodestar \
  beacon \
  --rootDir={{ .Values.global.ethereum.consensus.dataDir }} \
  --network.discv5.enabled=true \
  --network.discv5.bindAddr=/ip4/0.0.0.0/udp/{{ .Values.global.ethereum.consensus.config.ports.p2p_tcp }} \
  --network.localMultiaddrs=/ip4/0.0.0.0/tcp/{{ .Values.global.ethereum.consensus.config.ports.p2p_tcp }} \
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
  --api.rest.enabled=true \
  --api.rest.host=0.0.0.0 \
  --api.rest.port={{ .Values.global.ethereum.consensus.config.ports.http_api }} \
  --metrics.enabled=true \
  --metrics.listenAddr=0.0.0.0 \
  --metrics.serverPort={{ .Values.global.ethereum.consensus.config.ports.metrics }} \
  --eth1.enabled=true \
  --execution.urls="http://${POD_IP}:{{ .Values.global.ethereum.execution.config.ports.engine_api }}" \
  --logLevel={{ .Values.global.ethereum.consensus.logLevel }} \
{{- $networkArgs := ((get (get .Values.global.networkConfigs .Values.global.ethereum.network) "consensus").args).lodestar }}
{{- range $networkArgs }}
  {{ . }}
{{- end }}
{{- range .Values.extraArgs }}
  {{ . }}
{{- end }}
{{- end }}
