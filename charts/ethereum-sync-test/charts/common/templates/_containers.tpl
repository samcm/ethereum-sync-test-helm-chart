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
        

        if [[ "$CONSENSUS_STATUS" == "100" && "$EXECUTION_STATUS" == "100" ]]; then
          echo "Shutting down...";
          pkill geth;
          pkill lighthouse;
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
{{- end }}

