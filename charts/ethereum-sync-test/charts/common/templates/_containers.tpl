{{- define "common.containers" }}
- name: status-checker
  image: {{ .Values.statusChecker.image.repository }}:{{ .Values.statusChecker.image.tag }}
  imagePullPolicy: {{ .Values.statusChecker.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  command:
    - /bin/sh
  env:
  - name: POD_IP
    valueFrom:
      fieldRef:
        fieldPath: status.podIP
  args:
    - -c
    - >
      apk add curl;
      apk add jq;

      # Sleep to give time for the clients to boot up and find peers etc.
      sleep 5;

      while true;
      do
        EXECUTION_STATUS=$(/status/execution.sh);
        CONSENSUS_STATUS=$(/status/consensus.sh);

        echo "EXECUTION: $EXECUTION_STATUS%, CONSENSUS: $CONSENSUS_STATUS%"

        if [[ "$CONSENSUS_STATUS" == "100" && "$EXECUTION_STATUS" == "100" ]] || [[  -f "/data/kill-pod"  ]]; then
          echo "Shutting down...";
          pkill geth;
          pkill lighthouse;
          pkill beacon-chain;
          pkill prysm;
          pkill /bin/app;
          pkill consensus;
          pkill execution;
          ps ax | grep -v pause | grep -v "ps ax" | awk '{ if (NR!=1) print $1 }' |  cut -d " " -f 1  | xargs kill -SIGTERM;
          pkill /bin/app;
          pkill app;
          pkill ethereum-metrics-exporter;
          pkill ethereum;

          exit 0;
        fi

        sleep 5;
      done;
  resources:
{{- toYaml .Values.statusChecker.resources | nindent 4 }}
  volumeMounts:
    - name: storage
      mountPath: /data
    - name: status-checks
      mountPath: /status
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
{{- end }}

