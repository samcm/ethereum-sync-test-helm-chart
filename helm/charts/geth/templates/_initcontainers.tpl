{{- define "geth.initContainers" }}
{{- $initNodePort := .Values.initContainers.initNodeport }}
{{- $initGenesis := .Values.initContainers.initGenesis }}
{{- if .Values.p2pNodePort.enabled }}
- name: init-nodeport
  image: {{ $initNodePort.image.repository }}:{{ $initNodePort.image.tag }}
  imagePullPolicy: {{ $initNodePort.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0

  env:
  - name: POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  - name: NODE_NAME
    valueFrom:
      fieldRef:
        fieldPath: spec.nodeName
  command:
    - sh
    - -c
    - >
      export EXTERNAL_PORT=$(kubectl get services -l "pod in (${POD_NAME}), type in (p2p)" -o jsonpath='{.items[0].spec.ports[0].nodePort}');
      export EXTERNAL_IP=$(kubectl get nodes "${NODE_NAME}" -o jsonpath='{.status.addresses[?(@.type=="ExternalIP")].address}');
      echo "EXTERNAL_PORT=$EXTERNAL_PORT" >  /env/init-nodeport;
      echo "EXTERNAL_IP=$EXTERNAL_IP"     >> /env/init-nodeport;
      cat /env/init-nodeport;
  volumeMounts:
  - name: env-nodeport
    mountPath: /env
{{- end }}

- name: init-genesis
  image:  {{ .Values.global.ethereum.execution.client.image.repository }}:{{ .Values.global.ethereum.execution.client.image.tag }}
  pullPolicy: {{ .Values.global.ethereum.execution.client.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  env:
  - name: "ETH_BOOTNODE_URL"
    value: "{{ .Values.global.ethereum.execution.customNetwork.config.bootnodes }}"
  - name: "ETH_GETH_GENESIS_URL"
    value: "{{ .Values.global.ethereum.execution.customNetwork.config.genesis_geth }}"
    
  command:
    - sh
    - -ace
    - >
      BOOTNODE_URL=$ETH_BOOTNODE_URL;
      GENESIS_URI=$ETH_GETH_GENESIS_URL;
      if ! [ -f {{ .Values.global.ethereum.execution.dataDir }}/genesis_init_done ];
      then
        wget -O {{ .Values.global.ethereum.execution.dataDir }}/bootnode.txt $BOOTNODE_URL;
        wget -O {{ .Values.global.ethereum.execution.dataDir }}/genesis.json $GENESIS_URI;
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