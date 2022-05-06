{{- define "nethermind.initContainers" }}
{{- $initGenesis := .Values.initContainers.initGenesis }}
- name: exe-init-genesis
  image:  {{ .Values.initContainers.initGenesis.image.repository }}:{{ .Values.initContainers.initGenesis.image.tag }}
  imagePullPolicy: {{ .Values.initContainers.initGenesis.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  env:
  - name: "ETH_NETHERMIND"
    value: "{{ include "ethereum-sync-tests.executionConfig" . }}/nethermind_genesis.json"
    
  command:
    - sh
    - -ace
    - >
      if ! [ -f {{ .Values.global.ethereum.execution.dataDir }}/genesis_init_done ];
      then
        mkdir -p {{ .Values.global.ethereum.execution.dataDir }};
        ls /data;
        wget -O {{ .Values.global.ethereum.execution.dataDir }}/nethermind_genesis.json $ETH_NETHERMIND;
        touch {{ .Values.global.ethereum.execution.dataDir }}/genesis_init_done;
        echo "genesis init done";
      else
        echo "genesis is already initialized";
      fi;
  volumeMounts:
  - name: storage
    mountPath: "/data"
{{- end }}