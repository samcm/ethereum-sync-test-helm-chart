{{/*
# Default command
*/}}
{{- define "geth.defaultCommand" -}}
{{- $staticPeers :=  (get (get .Values.global.networkConfigs .Values.global.ethereum.network) "execution").static_peers }}
{{- if $staticPeers }}
  echo '{{ toJson $staticPeers }}' > $(DATADIR)/geth/trusted-nodes.json; \
  echo '{{ toJson $staticPeers }}' > $(DATADIR)/geth/static-nodes.json; \
{{- end }}
{{- if .Values.global.p2pNodePort.enabled }}
  . /env/init-nodeport; \
{{- end }}
  geth \
  --datadir="$(DATADIR)" \
{{- if .Values.global.p2pNodePort.enabled }}
  --nat=extip:$EXTERNAL_IP \
  --port=$EXTERNAL_EXECUTION_PORT \
{{- else }}
  --nat=extip:$(POD_IP) \
  --port={{ .Values.global.ethereum.execution.config.ports.p2p_tcp }} \
{{- end }}
  --http \
  --http.addr=0.0.0.0 \
  --http.port={{ .Values.global.ethereum.execution.config.ports.http_rpc  }} \
  --http.api="engine,net,eth,web3,txpool" \
  --http.vhosts=* \
  --http.corsdomain=* \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port={{ .Values.global.ethereum.execution.config.ports.ws_rpc  }} \
  --ws.origins=* \
  --ws.api="engine,net,eth,web3,txpool" \
  --metrics \
  --metrics.addr=0.0.0.0 \
  --metrics.port={{ .Values.global.ethereum.execution.config.ports.metrics  }} \
  --authrpc.jwtsecret="/data/jwtsecret" \
  --authrpc.port={{ .Values.global.ethereum.execution.config.ports.engine_api  }} \
  --authrpc.vhosts=* \
  --authrpc.addr=0.0.0.0 \
{{- range .Values.extraArgs }}
  {{ . }}
{{- end }}
{{- $networkArgs := ((get (get .Values.global.networkConfigs .Values.global.ethereum.network) "execution").args).geth }}
{{- range $networkArgs }}
  {{ . }}
{{- end }}

{{- end }}
