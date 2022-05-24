{{- define "common.containers" }}
{{- if .Values.metricsExporter.enabled }}
- name: metrics-exporter
  image: {{ .Values.metricsExporter.image.repository }}:{{ .Values.metricsExporter.image.tag }}
  imagePullPolicy: {{ .Values.metricsExporter.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  env:
  - name: POD_IP
    valueFrom:
      fieldRef:
        fieldPath: status.podIP
  args:
    - --consensus-url=http://localhost:{{ .Values.global.ethereum.consensus.config.ports.http_api }}
    - --execution-url=http://localhost:{{ .Values.global.ethereum.execution.config.ports.http_rpc }}
    - --monitored-directories={{ .Values.global.ethereum.consensus.dataDir }},{{ .Values.global.ethereum.execution.dataDir }}
    - --metrics-port={{ .Values.metricsExporter.port }}
  ports:
  - containerPort: {{ .Values.metricsExporter.port }}
    name: eth-metrics
    protocol: TCP
  volumeMounts:
  - name: storage
    mountPath: /data
  resources:
{{- toYaml .Values.metricsExporter.resources | nindent 4 }}
{{- end }}

{{- if .Values.coordinator.enabled }}
- name: coordinator
  image: {{ .Values.coordinator.image.repository }}:{{ .Values.coordinator.image.tag }}
  imagePullPolicy: {{ .Values.coordinator.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  env:
  - name: EXECUTION_CLIENT_NAME
    value: {{ .Values.global.ethereum.execution.client.name }}
  - name: CONSENSUS_CLIENT_NAME
    value: {{ .Values.global.ethereum.consensus.client.name }}
  args:
    - --config=/config/config.yaml
  ports:
  - containerPort: {{ .Values.coordinator.port }}
    name: coord-metrics
    protocol: TCP
  volumeMounts:
  - name: coordinator-config
    mountPath: /config
  resources:
{{- toYaml .Values.coordinator.resources | nindent 4 }}
{{- end }}
{{- end }}

