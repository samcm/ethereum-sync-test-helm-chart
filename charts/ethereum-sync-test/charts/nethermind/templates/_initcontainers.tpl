{{- define "nethermind.initContainers" }}
{{- $initGenesis := .Values.initContainers.initGenesis }}
{{- if .Values.initContainers.initGenesis.enabled }}
- name: exe-init-genesis
  image:  {{ .Values.initContainers.initGenesis.image.repository }}:{{ .Values.initContainers.initGenesis.image.tag }}
  imagePullPolicy: {{ .Values.initContainers.initGenesis.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  env:
  {{- include "ethereum-sync-tests.execution-config-env" . | nindent 4}}
    
  command:
    - sh
    - -ace
    - >
      if ! [ -f {{ .Values.global.ethereum.execution.dataDir }}/genesis_init_done ];
      then
        mkdir -p {{ .Values.global.ethereum.execution.dataDir }};
        ls /data;
        wget -O {{ .Values.global.ethereum.execution.dataDir }}/nethermind_genesis.json $NETHERMIND_GENESIS_JSON;
        wget -O {{ .Values.global.ethereum.execution.dataDir }}/bootnode.txt $BOOTNODES;
        touch {{ .Values.global.ethereum.execution.dataDir }}/genesis_init_done;
        echo "genesis init done";
      else
        echo "genesis is already initialized";
      fi;
  volumeMounts:
  - name: storage
    mountPath: "/data"
{{- end }}
{{- end }}