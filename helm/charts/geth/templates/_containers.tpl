{{- define "geth.containers" }}
- image: {{ .Values.global.ethereum.execution.client.image.repository }}:{{ .Values.global.ethereum.execution.client.image.tag }}
  name: geth
  imagePullPolicy: {{ .Values.global.ethereum.execution.client.image.pullPolicy }}
  command:
  {{- if gt (len .Values.customCommand) 0 }}
    {{- toYaml .Values.customCommand | nindent 2}}
  {{- else }}
    {{- include "geth.defaultCommand" . | nindent 2 }}
  {{- end }}
  env:
  - name: POD_IP
    valueFrom:
      fieldRef:
        fieldPath: status.podIP
  volumeMounts:
  {{- if .Values.extraVolumeMounts }}
    {{ toYaml .Values.extraVolumeMounts | nindent 8}}
  {{- end }}
  - name: storage
    mountPath: /data
  {{- if .Values.global.p2pNodePort.enabled }}
  - name: env-nodeport
    mountPath: /env
  {{- end }}
  - name: config
    mountPath: "/config"
    readOnly: true
  ports:
  {{- if .Values.extraContainerPorts }}
    {{ toYaml .Values.extraContainerPorts | nindent 8 }}
  {{- end }}
  - name: exe-p2p-tcp
    containerPort: {{ .Values.global.ethereum.execution.config.ports.p2p_tcp }}
    protocol: TCP
  - name: exe-p2p-udp
    containerPort: {{ .Values.global.ethereum.execution.config.ports.p2p_udp }}
    protocol: UDP
  - name: exe-http-rpc
    containerPort: {{ .Values.global.ethereum.execution.config.ports.http_rpc }}
    protocol: TCP
  - name: exe-ws-rpc
    containerPort: {{ .Values.global.ethereum.execution.config.ports.ws_rpc }}
    protocol: TCP
  - name: exe-metrics
    containerPort: {{ .Values.global.ethereum.execution.config.ports.metrics }}
    protocol: TCP
  {{- if .Values.livenessProbe }}
  livenessProbe:
    {{- toYaml .Values.livenessProbe | nindent 4 }}
  {{- end }}
  {{- if .Values.readinessProbe }}
  readinessProbe:
    {{- toYaml .Values.readinessProbe | nindent 4 }}
  {{- end }}
  resources:
    {{- toYaml .Values.resources | nindent 4 }}
{{- end }}

