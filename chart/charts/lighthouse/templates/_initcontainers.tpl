{{- define "lighthouse.initContainers" }}
{{- $initGenesis := .Values.initContainers.initGenesis }}
- name: con-init-genesis
  image:  {{ .Values.initContainers.initGenesis.image.repository }}:{{ .Values.initContainers.initGenesis.image.tag }}
  imagePullPolicy: {{ .Values.initContainers.initGenesis.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  env:
  - name: "ETH_BOOTNODE_URI"
    value: "{{  get (get (get .Values.global.networkConfigs .Values.global.ethereum.network) "consensus") "bootnodes"  }}"
  - name: "DEPOSIT_CONTRACT_URI"
    value: "{{ get (get (get .Values.global.networkConfigs .Values.global.ethereum.network) "consensus") "deposit_contract.txt"  }}"
  - name: "DEPOSIT_CONTRACT_BLOCK_URI"
    value: "{{ get (get (get .Values.global.networkConfigs .Values.global.ethereum.network) "consensus") "deposit_contract_block.txt"  }}"
  - name: "DEPLOY_BLOCK_URI"
    value: "{{ get (get (get .Values.global.networkConfigs .Values.global.ethereum.network) "consensus") "deploy_block.txt"  }}"
  - name: "GENESIS_CONFIG_URI"
    value: "{{ get (get (get .Values.global.networkConfigs .Values.global.ethereum.network) "consensus") "config.yaml"  }}"
  - name: "GENESIS_SSZ_URI"
    value: "{{ get (get (get .Values.global.networkConfigs .Values.global.ethereum.network) "consensus") "genesis.ssz"  }}"
  command:
    - sh
    - -ace
    - >
      mkdir -p {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec;
      if ! [ -f {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/genesis.ssz ];
      then
        wget -O {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/deposit_contract.txt $DEPOSIT_CONTRACT_URI;
        wget -O {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/deposit_contract_block.txt $DEPOSIT_CONTRACT_BLOCK_URI;
        wget -O {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/deploy_block.txt $DEPLOY_BLOCK_URI;
        wget -O {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/config.yaml $GENESIS_CONFIG_URI;
        wget -O {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/genesis.ssz $GENESIS_SSZ_URI;
        wget -O {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/bootstrap_nodes.txt $ETH_BOOTNODE_URI;
        echo "genesis init done";
      else
        echo "genesis exists. skipping...";
      fi;
      echo "bootnode init done: $(cat {{ .Values.global.ethereum.consensus.dataDir }}/testnet_spec/bootstrap_nodes.txt)";
  volumeMounts:
  - name: storage
    mountPath: "/data"
{{- end }}