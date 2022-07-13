{{- define "nimbus.initContainers" }}
{{- $initGenesis := .Values.initContainers.initGenesis }}
{{- if .Values.global.ethereum.consensus.dataDir }}
- name: con-init-genesis
  image:  {{ .Values.initContainers.initGenesis.image.repository }}:{{ .Values.initContainers.initGenesis.image.tag }}
  imagePullPolicy: {{ .Values.initContainers.initGenesis.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  env:
  {{- include "ethereum-sync-tests.consensus-config-env" . | nindent 4 }}
  command:
    - sh
    - -ace
    - >
      mkdir -p {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec;
      if ! [ -f {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/genesis.ssz ];
      then
        wget -O {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/config.yaml $CONFIG_YAML;
        wget -O {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/genesis.ssz $GENESIS_SSZ;
        wget -O {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/bootstrap_nodes.txt $BOOTNODES;
        wget -O {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/deploy_block.txt $DEPLOY_BLOCK_TXT;
        wget -O {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/deposit_contract.txt $DEPOSIT_CONTRACT_TXT;
        wget -O {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/deposit_contract_block.txt $DEPOSIT_CONTRACT_BLOCK_TXT;
        echo "genesis init done";
      else
        echo "genesis exists. skipping...";
      fi;
      echo "bootnode init done: $(cat {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/bootstrap_nodes.txt)";
  volumeMounts:
  - name: storage
    mountPath: "/data"
{{- end }}
{{- if .Values.global.ethereum.consensus.checkpointSync.enabled }}
- name: con-init-checkpointsync
  image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  env:
  {{- include "ethereum-sync-tests.consensus-config-env" . | nindent 4 }}
  command:
    - {{ .Values.defaultBinaryPath }}
    - trustedNodeSync 
    - --data-dir={{ .Values.global.ethereum.consensus.dataDir }}
    - --network={{ .Values.global.ethereum.network }}
    - --backfill=false
    - --trusted-node-url={{ .Values.global.ethereum.consensus.checkpointSync.nodeUrl }}
  volumeMounts:
  - name: storage
    mountPath: "/data"
{{- end }}
{{- end }}