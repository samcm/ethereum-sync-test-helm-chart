{{/*
# Beacon command
*/}}
{{- define "nethermind.defaultCommand" -}}
{{- if .Values.global.p2pNodePort.enabled }}
  . /env/init-nodeport; \
{{- end }}
  /nethermind/Nethermind.Runner \
  --datadir={{ .Values.global.ethereum.execution.dataDir }} \
  --KeyStore.KeyStoreDirectory={{ .Values.global.ethereum.execution.dataDir }}/keystore \
  --Network.LocalIp=$(POD_IP) \
{{- if .Values.global.p2pNodePort.enabled }}
  --Network.ExternalIp=$EXTERNAL_IP \
  --Network.P2PPort=$EXTERNAL_EXECUTION_PORT \
  --Network.DiscoveryPort=$EXTERNAL_EXECUTION_PORT \
{{- else }}
  --Network.ExternalIp=$(POD_IP) \
  --Network.P2PPort={{ .Values.global.ethereum.execution.config.ports.p2p_tcp }} \
  --Network.DiscoveryPort={{ .Values.global.ethereum.execution.config.ports.p2p_tcp }} \
{{- end }}
  --JsonRpc.Enabled=true \
  --JsonRpc.EnabledModules="net,eth,consensus,subscribe,web3,txpool" \
  --JsonRpc.Host=0.0.0.0 \
  --JsonRpc.Port={{ .Values.global.ethereum.execution.config.ports.http_rpc }} \
  --Init.WebSocketsEnabled=true \
  --Init.DiagnosticMode="None" \
  --JsonRpc.WebSocketsPort={{ .Values.global.ethereum.execution.config.ports.ws_rpc }} \
  --Metrics.Enabled=true \
  --log=ERROR \
  --Metrics.ExposePort={{ .Values.global.ethereum.execution.config.ports.metrics }} \
  --JsonRpc.AdditionalRpcUrls="o-auth,http://0.0.0.0:{{ .Values.global.ethereum.execution.config.ports.engine_api }}|http;ws|net;eth;subscribe;engine;web3;client" \
  --JsonRpc.JwtSecretFile="/data/jwtsecret" \
{{- $networkArgs := ((get (get .Values.global.networkConfigs .Values.global.ethereum.network) "execution").args).nethermind }}
{{- range $networkArgs }}
  {{ . }}
{{- end }}
{{- range .Values.extraArgs }}
  {{ . }}
{{- end }}
{{- end }}
