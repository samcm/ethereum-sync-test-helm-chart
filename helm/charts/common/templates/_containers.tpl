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

      while true;
      do
        EXECUTION_STATUS=$(/status/execution.sh);
        CONSENSUS_STATUS=$(/status/consensus.sh);

        echo "EXECUTION_STATUS: $EXECUTION_STATUS%, CONSENSUS_STATUS: $CONSENSUS_STATUS%"
        

        if [ "$CONSENSUS_STATUS" == "100" ]; then
          echo "Shutting down...";
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
{{- end }}

