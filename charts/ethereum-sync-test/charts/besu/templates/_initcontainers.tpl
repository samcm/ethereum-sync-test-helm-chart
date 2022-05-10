{{- define "besu.initContainers" }}
{{- $initGenesis := .Values.initContainers.initGenesis }}
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
        apk update && apk add jq;
        wget -O {{ .Values.global.ethereum.execution.dataDir }}/bootnode.txt $BOOTNODES;
        wget -O {{ .Values.global.ethereum.execution.dataDir }}/besu_genesis.json $BESU_GENESIS_JSON;
        cat {{ .Values.global.ethereum.execution.dataDir }}/besu_genesis.json | jq -r '.config.chainId' > {{ .Values.global.ethereum.execution.dataDir }}/chainid.txt;
        touch {{ .Values.global.ethereum.execution.dataDir }}/genesis_init_done;
        echo "genesis init done";
      else
        echo "genesis is already initialized";
      fi;
  volumeMounts:
  - name: storage
    mountPath: "/data"
{{- end }}