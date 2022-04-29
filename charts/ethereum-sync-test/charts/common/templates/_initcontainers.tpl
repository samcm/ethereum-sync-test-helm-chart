{{- define "common.initContainers" }}
{{- $p2pNodePort := .Values.global.p2pNodePort }}
{{- $generateJWT := .Values.global.initContainers.generateJWT }}

{{- if .Values.global.initContainers.initChownData.enabled }}
- name: init-chown-data
  image: "{{ .Values.global.initContainers.initChownData.image.repository }}:{{ .Values.global.initContainers.initChownData.image.tag }}"
  imagePullPolicy: {{ .Values.global.initContainers.initChownData.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  command: ["chown", "-R", "{{ .Values.global.securityContext.runAsUser }}:{{ .Values.global.securityContext.runAsGroup }}", "/data"]
  resources:
{{- toYaml .Values.global.initContainers.initChownData.resources | nindent 4 }}
  volumeMounts:
    - name: storage
      mountPath: "/data"
{{- end }}
{{- if .Values.global.initContainers.initStorage.enabled }}
- name: init-storage
  image: {{ .Values.global.initContainers.initStorage.image.repository }}:{{ .Values.global.initContainers.initStorage.image.tag }}
  imagePullPolicy: {{ .Values.global.initContainers.initStorage.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  command:
   {{- toYaml .Values.global.initContainers.initStorage.command | nindent 4}}
  args:
   {{- toYaml .Values.global.initContainers.initStorage.args | nindent 4 }}
  volumeMounts:
  - name: storage
    mountPath: /data
{{- end }}
{{- if $p2pNodePort.enabled }}
- name: init-nodeport
  image: {{ $p2pNodePort.initContainer.image.repository }}:{{ $p2pNodePort.initContainer.image.tag }}
  imagePullPolicy: {{ $p2pNodePort.initContainer.pullPolicy }}
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
      {{- if $p2pNodePort.publicIP }}
      export EXTERNAL_IP="{{ $p2pNodePort.publicIP }}";
      {{- else }}
      export EXTERNAL_IP=$(kubectl get nodes "${NODE_NAME}" -o jsonpath='{.status.addresses[?(@.type=="ExternalIP")].address}');
      {{- end }}
      export EXTERNAL_EXECUTION_PORT={{ .Values.global.ethereum.execution.config.ports.p2p_tcp }};
      export EXTERNAL_CONSENSUS_PORT={{ .Values.global.ethereum.consensus.config.ports.p2p_tcp }};
      echo "EXTERNAL_EXECUTION_PORT=$EXTERNAL_EXECUTION_PORT" >  /env/init-nodeport;
      echo "EXTERNAL_CONSENSUS_PORT=$EXTERNAL_CONSENSUS_PORT" >>  /env/init-nodeport;
      echo "EXTERNAL_IP=$EXTERNAL_IP"     >> /env/init-nodeport;
      cat /env/init-nodeport;
  volumeMounts:
  - name: env-nodeport
    mountPath: /env
{{- end }}
{{- if $generateJWT.enabled }}
- name: generate-jwt
  image: {{ $generateJWT.image.repository }}:{{ $generateJWT.image.tag }}
  imagePullPolicy: {{ $generateJWT.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  command:
    {{ toYaml $generateJWT.command | nindent 4 }}
  volumeMounts:
  - name: storage
    mountPath: /data
{{- else }}
- name: insert-jwt
  image: {{ $generateJWT.image.repository }}:{{ $generateJWT.image.tag }}
  imagePullPolicy: {{ $generateJWT.image.pullPolicy }}
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
  command:
    - /bin/sh
  args:
    - -c
    - >
      echo "{{ .Values.global.jwtsecret }}" > /data/jwtsecret
  resources:
{{- toYaml $generateJWT.resources | nindent 4 }}
  volumeMounts:
  - name: storage
    mountPath: /data
{{- end }}

{{- end }}