{{/*
# Beacon command
*/}}
{{- define "nimbus.beaconCommand" -}}
- sh
- -ac
- >
{{- if .Values.global.p2pNodePort.enabled }}
  . /env/init-nodeport;
{{- end }}
  trap 'exit 0' INT TERM;
  {{ .Values.defaultBinaryPath }}
  --data-dir={{ .Values.global.ethereum.consensus.dataDir }}
  --enr-auto-update=false
  --non-interactive=true
{{- if .Values.global.p2pNodePort.enabled }}
  --nat=extip:$EXTERNAL_IP
  --tcp-port=$EXTERNAL_CONSENSUS_PORT
  --udp-port=$EXTERNAL_CONSENSUS_PORT
{{- else }}
  --nat=extip:$(POD_IP)
  --tcp-port={{ .Values.global.ethereum.consensus.config.ports.p2p_tcp }}
  --udp-port={{ .Values.global.ethereum.consensus.config.ports.p2p_udp }}
{{- end }}
  --web3-url="ws://${POD_IP}:{{ .Values.global.ethereum.execution.config.ports.engine_api }}"
  --rest=true
  --rest-address=0.0.0.0
  --rest-port={{ .Values.global.ethereum.consensus.config.ports.http_api }}
  --metrics=true
  --metrics-address=0.0.0.0
  --metrics-port={{ .Values.global.ethereum.consensus.config.ports.metrics }}
  --log-level={{ upper .Values.global.ethereum.consensus.logLevel }}
  --use-jwt-debug=true
  --jwt-secret="/data/jwtsecret"
  {{- $networkArgs := ((get (get .Values.global.networkConfigs .Values.global.ethereum.network) "consensus").args).nimbus }}
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
{{- define "nimbus.sync-status-check-command" -}}
#!/bin/sh
head=$(curl -s $POD_IP:5052/eth/v1/node/syncing | jq -e '.data.head_slot|tonumber' || echo 0);
distance=$(curl -s $POD_IP:5052/eth/v1/node/syncing | jq -e '.data.sync_distance|tonumber' || echo 100000);
highest=$((head + distance));
if [ $highest == 0 ]; then
  echo -ne "0";
else
  percent=$((100 * head / highest)) || echo 0;
  echo -ne "$percent";
fi;
{{- end }}