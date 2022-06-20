{{- define "erigon.initContainers" }}
{{- $initGenesis := .Values.initContainers.initGenesis }}
{{- if .Values.initContainers.initGenesis.enabled }}
- name: exe-init-genesis
  image:  {{ .Values.image.repository }}:{{ .Values.image.tag }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  env:
  {{- include "ethereum-sync-tests.execution-config-env" . | nindent 4 }}
    
  command:
    - sh
    - -ace
    - >
      if ! [ -f {{ .Values.global.ethereum.execution.dataDir }}/genesis_init_done ];
      then
        mkdir -p {{ .Values.global.ethereum.execution.dataDir }};
        ls /data;
        wget -O {{ .Values.global.ethereum.execution.dataDir }}/bootnode.txt $BOOTNODES;
        wget -O {{ .Values.global.ethereum.execution.dataDir }}/genesis.json $GENESIS_GETH;
        apk update && apk add jq;
        cat {{ .Values.global.ethereum.execution.dataDir }}/genesis.json | jq -r '.config.chainId' > {{ .Values.global.ethereum.execution.dataDir }}/chainid.txt;
        erigon --datadir={{ .Values.global.ethereum.execution.dataDir }} init {{ .Values.global.ethereum.execution.dataDir }}/genesis.json
        touch {{ .Values.global.ethereum.execution.dataDir }}/genesis_init_done;
        echo "genesis init done";
      else
        echo "genesis is already initialized";
      fi;
      echo "bootnode init done: $(cat {{ .Values.global.ethereum.execution.dataDir }}/bootnode.txt)";
  volumeMounts:
  - name: storage
    mountPath: "/data"
{{- end }}
{{- end }}