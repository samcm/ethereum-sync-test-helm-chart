{{- define "teku.containers" }}
- image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
  name: teku-beacon
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  command:
  {{- if gt (len .Values.customCommand) 0 }}
    {{- toYaml .Values.customCommand | nindent 2}}
  {{- else }}
    {{- include "teku.beaconCommand" . | nindent 2 }}
  {{- end }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  env:
  - name: POD_IP
    valueFrom:
      fieldRef:
        fieldPath: status.podIP
  {{- if .Values.extraEnv }}
  {{- toYaml .Values.extraEnv | nindent 2 }}
  {{- end }}
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
  - name: con-p2p-tcp
    containerPort: {{ .Values.global.ethereum.consensus.config.ports.p2p_tcp }}
    protocol: TCP
  - name: con-p2p-udp
    containerPort: {{ .Values.global.ethereum.consensus.config.ports.p2p_udp }}
    protocol: UDP
  - name: con-http-api
    containerPort: {{ .Values.global.ethereum.consensus.config.ports.http_api }}
    protocol: TCP
  - name: con-metrics
    containerPort: {{ .Values.global.ethereum.consensus.config.ports.metrics }}
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

