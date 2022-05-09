{{/*
# Beacon command
*/}}
{{- define "teku.beaconCommand" -}}
- sh
- -ac
- >
{{- if .Values.global.p2pNodePort.enabled }}
  . /env/init-nodeport;
{{- end }}
  exec /opt/teku/bin/teku
  --log-destination=CONSOLE
  --data-path={{ .Values.global.ethereum.consensus.dataDir }}
  --p2p-enabled=true
{{- if .Values.global.p2pNodePort.enabled }}
  --p2p-advertised-ip=$EXTERNAL_IP
  --p2p-advertised-port=$EXTERNAL_CONSENSUS_PORT
{{- else }}
  --p2p-advertised-ip=$(POD_IP)
  --p2p-advertised-port={{ .Values.global.ethereum.consensus.config.ports.p2p_tcp }}
{{- end }}
  --rest-api-enabled=true
  --rest-api-interface=0.0.0.0
  --rest-api-host-allowlist=*
  --rest-api-port={{ .Values.global.ethereum.consensus.config.ports.http_api }}
  --metrics-enabled=true
  --metrics-interface=0.0.0.0
  --metrics-host-allowlist=*
  --metrics-port={{ .Values.global.ethereum.consensus.config.ports.metrics }}
  --ee-jwt-secret-file="/data/jwtsecret"
  --eth1-endpoints="http://${POD_IP}:{{ .Values.global.ethereum.execution.config.ports.http_rpc }}"
  --ee-endpoint="http://${POD_IP}:{{ .Values.global.ethereum.execution.config.ports.engine_api }}"
  --data-storage-mode=PRUNE
{{- $networkArgs := ((get (get .Values.global.networkConfigs .Values.global.ethereum.network) "consensus").args).teku }}
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
{{- define "teku.sync-status-check-command" -}}
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