{{- define "prysm.initContainers" }}
{{- $initGenesis := .Values.initContainers.initGenesis }}
{{- if .Values.initContainers.initGenesis.enabled }}
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
        echo "genesis init done";
      else
        echo "genesis exists. skipping...";
      fi;
      echo "bootnode init done: $(cat {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/bootstrap_nodes.txt)";
  volumeMounts:
  - name: storage
    mountPath: "/data"
{{- end }}
{{- end }}