{{/*
# Beacon command
*/}}
{{- define "prysm.beaconCommand" -}}
- sh
- -ac
- >
{{- if .Values.global.p2pNodePort.enabled }}
  . /env/init-nodeport;
{{- end }}
  trap 'exit 0' INT TERM;
  /app/cmd/beacon-chain/beacon-chain
  --accept-terms-of-use=true
  --datadir={{ .Values.global.ethereum.consensus.dataDir }}
{{- if .Values.global.p2pNodePort.enabled }}
  --p2p-host-ip=$EXTERNAL_IP
  --p2p-tcp-port=$EXTERNAL_CONSENSUS_PORT
  --p2p-udp-port=$EXTERNAL_CONSENSUS_PORT
{{- else }}
  --p2p-host-ip=$(POD_IP)
  --p2p-tcp-port={{ .Values.global.ethereum.consensus.config.ports.p2p_tcp }}
  --p2p-udp-port={{ .Values.global.ethereum.consensus.config.ports.p2p_udp }}
{{- end }}
  --rpc-host=0.0.0.0
  --rpc-port={{ .Values.global.ethereum.consensus.config.ports.rpc }}
  --grpc-gateway-host=0.0.0.0
  --grpc-gateway-port={{ .Values.global.ethereum.consensus.config.ports.http_api }}
  --monitoring-host=0.0.0.0
  --monitoring-port={{ .Values.global.ethereum.consensus.config.ports.metrics }}
  --http-web3provider="http://${POD_IP}:{{ .Values.global.ethereum.execution.config.ports.engine_api }}"
  --jwt-secret="/data/jwtsecret"
  {{- $networkArgs := ((get (get .Values.global.networkConfigs .Values.global.ethereum.network) "consensus").args).prysm }}
{{- range $networkArgs }}
  {{ . }}
{{- end }}
{{- range .Values.extraArgs }}
  {{ . }}
{{- end }}
{{- end }}
