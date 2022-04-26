{{- define "geth.initContainers" }}
{{- $initGenesis := .Values.initContainers.initGenesis }}
- name: exe-init-genesis
  image:  {{ .Values.global.ethereum.execution.client.image.repository }}:{{ .Values.global.ethereum.execution.client.image.tag }}
  imagePullPolicy: {{ .Values.global.ethereum.execution.client.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  env:
  - name: "ETH_BOOTNODE_URL"
    value: "{{  get (get (get .Values.global.networkConfigs .Values.global.ethereum.network) "execution") "bootnodes"  }}"
  - name: "ETH_GETH_GENESIS_URL"
    value: "{{ get (get (get .Values.global.networkConfigs .Values.global.ethereum.network) "execution") "genesis_geth"  }}"
    
  command:
    - sh
    - -ace
    - >
      if ! [ -f {{ .Values.global.ethereum.execution.dataDir }}/genesis_init_done ];
      then
        mkdir -p {{ .Values.global.ethereum.execution.dataDir }};
        ls /data;
        wget -O {{ .Values.global.ethereum.execution.dataDir }}/bootnode.txt $ETH_BOOTNODE_URL;
        wget -O {{ .Values.global.ethereum.execution.dataDir }}/genesis.json $ETH_GETH_GENESIS_URL;
        apk update && apk add jq;
        cat {{ .Values.global.ethereum.execution.dataDir }}/genesis.json | jq -r '.config.chainId' > {{ .Values.global.ethereum.execution.dataDir }}/chainid.txt;
        geth init --datadir {{ .Values.global.ethereum.execution.dataDir }} {{ .Values.global.ethereum.execution.dataDir }}/genesis.json;
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