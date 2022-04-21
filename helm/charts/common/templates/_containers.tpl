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
      tee /data/execution_check.sh << END
        #!/bin/sh
{{- include "ethereum-sync-tests.status-checking" . | nindent 8 }} && echo "COMPLETED" || echo "SYNCING";
        
      END

      chmod +x /data/execution_check.sh

      while true;
      do
        EXECUTION_STATUS=$(/data/execution_check.sh);
        CONSENSUS_STATUS=

        echo "EXECUTION_STATUS: $EXECUTION_STATUS, CONSENSUS_STATUS: $CONSENSUS_STATUS"
        

        if [ "$EXECUTION_STATUS" == "COMPLETED" ]; then
          echo "Shutting down...";
          pkill -SIGTERM geth;
          exit 0;
        fi

        sleep 5;
      done;
  resources:
{{- toYaml .Values.statusChecker.resources | nindent 4 }}
  volumeMounts:
    - name: storage
      mountPath: /data
{{- end }}

