{{/*
Expand the name of the chart.
*/}}
{{- define "ethereum-sync-tests.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ethereum-sync-tests.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ethereum-sync-tests.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ethereum-sync-tests.labels" -}}
helm.sh/chart: {{ include "ethereum-sync-tests.chart" . }}
{{ include "ethereum-sync-tests.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
consensus_client: {{ .Values.global.ethereum.consensus.client.name | quote }}
execution_client: {{ .Values.global.ethereum.execution.client.name | quote }}
network: {{ .Values.global.ethereum.network | quote }}
testnet: {{ .Values.global.ethereum.network | quote }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ethereum-sync-tests.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ethereum-sync-tests.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ethereum-sync-tests.serviceAccountName" -}}
{{- if .Values.rbac.create }}
{{- default (include "ethereum-sync-tests.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Execution Config Environment Variables
*/}}
{{- define "ethereum-sync-tests.execution-config-env" -}}
{{- $exe := (get (get .Values.global.networkConfigs .Values.global.ethereum.network) "execution").config }}
{{- range $key, $value := $exe }}
- name: {{ upper $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
Consensus Config Environment Variables
*/}}
{{- define "ethereum-sync-tests.consensus-config-env" -}}
{{- $con := (get (get .Values.global.networkConfigs .Values.global.ethereum.network) "consensus").config }}
{{- range $key, $value := $con }}
- name: {{ upper $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
Helpers to grab the consensus network configs
*/}}
{{- define "ethereum-sync-tests.consensusConfig" -}}https://raw.githubusercontent.com/eth-clients/merge-testnets/main/{{ .Values.global.ethereum.network }}{{- end }}

{{/*
Helpers to grab the execution network configs
*/}}
{{- define "ethereum-sync-tests.executionConfig" -}}https://raw.githubusercontent.com/eth-clients/merge-testnets/main/{{ .Values.global.ethereum.network }}{{- end }}


{{/*
Execution client command 
*/}}
{{- define "ethereum-sync-tests.execution-client-command" -}}
{{- if eq .Values.global.ethereum.execution.client.name "geth" }}
{{ include "geth.defaultCommand" . }}
{{- end }}
{{- if eq .Values.global.ethereum.execution.client.name "nethermind" }}
{{ include "nethermind.defaultCommand" . }}
{{- end }}
{{- if eq .Values.global.ethereum.execution.client.name "besu" }}
{{ include "besu.defaultCommand" . }}
{{- end }}
{{- end }}

{{/*
Full Execution Command 
*/}}
{{- define "ethereum-sync-tests.full-execution-command" -}}
- sh
- -ac
- >
  while true; do
    if [ -f /data/execution/running ]; then    
      rm /data/execution/running;
    fi

    if [ -f /data/execution/finished ]; then
      echo "Execution client has been told to shut down permanently.."
      exit 0;
    fi

    if [ -f /data/execution/stop ]; then
      echo "Execution client is not allowed to startup.."
      sleep 5;
      continue;
    fi

    touch /data/execution/running;

    trap 'echo "caught interuption signal.."; continue' INT;
    {{ include "ethereum-sync-tests.execution-client-command" . | indent 2}}
    sleep 1;
  done
{{- end }}

{{/*
Consensus client command 
*/}}
{{- define "ethereum-sync-tests.consensus-client-command" -}}
{{- if eq .Values.global.ethereum.consensus.client.name "prysm" }}
{{ include "prysm.beaconCommand" . }}
{{- end }}
{{- if eq .Values.global.ethereum.consensus.client.name "nimbus" }}
{{ include "nimbus.beaconCommand" . }}
{{- end }}
{{- if eq .Values.global.ethereum.consensus.client.name "lighthouse" }}
{{ include "lighthouse.beaconCommand" . }}
{{- end }}
{{- if eq .Values.global.ethereum.consensus.client.name "teku" }}
{{ include "teku.beaconCommand" . }}
{{- end }}
{{- if eq .Values.global.ethereum.consensus.client.name "lodestar" }}
{{ include "lodestar.beaconCommand" . }}
{{- end }}
{{- end }}

{{/*
Full Consensus Command 
*/}}
{{- define "ethereum-sync-tests.full-consensus-command" -}}
- sh
- -ac
- >
  while true; do
    if [ -f /data/consensus/running ]; then    
      rm /data/consensus/running;
    fi

    if [ -f /data/consensus/finished ]; then
      echo "Consensus client has been told to shut down permanently.."
      exit 0;
    fi

    if [ -f /data/consensus/stop ]; then
      echo "Consensus client is not allowed to startup.."
      sleep 5;
      continue;
    fi

    touch /data/consensus/running;

    trap 'echo "caught interuption signal.."; continue' INT;
    {{ include "ethereum-sync-tests.consensus-client-command" . | indent 2}}
    sleep 1;
  done
{{- end }}

{{/*
Pod Spec
*/}}
{{- define "ethereum-sync-tests.pod-spec" -}}
initContainers:
{{ include "ethereum-sync-tests.initContainers" . | nindent 2 }}
containers:
{{ include "ethereum-sync-tests.containers" . | nindent 2 }}
volumes:
{{ include "ethereum-sync-tests.volumes" . | nindent 2 }}
nodeSelector:
{{- toYaml .Values.nodeSelector | nindent 2 }}
affinity:
{{- toYaml .Values.affinity | nindent 2 }}
tolerations:
{{- toYaml .Values.tolerations | nindent 2 }}
restartPolicy: {{ .Values.cronjob.job.restartPolicy | quote }}
shareProcessNamespace: true
{{- if .Values.rbac.create }}
serviceAccountName: {{ include "ethereum-sync-tests.serviceAccountName" . }}
{{- end }}
{{- if .Values.cronjob.job.terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ .Values.cronjob.job.terminationGracePeriodSeconds }}
{{- end }}
{{- end }}

{{/*
Pod Template
*/}}
{{- define "ethereum-sync-tests.pod-template" -}}
metadata:
  labels:
  {{- include "ethereum-sync-tests.labels" . | nindent 4 }}
  {{- with .Values.podLabels }}
  {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.podAnnotations }}
  annotations:
  {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- include "ethereum-sync-tests.pod-spec" . | nindent 2 }}
{{- end }}

{{/*
Job Template
*/}}
{{- define "ethereum-sync-tests.job-spec" -}}
backoffLimit: {{ .Values.cronjob.job.backoffLimit }}
{{- if .Values.cronjob.activeDeadlineSeconds }}
activeDeadlineSeconds: {{ .Values.cronjob.activeDeadlineSeconds }}
{{- end }}
{{- if .Values.cronjob.job.ttlSecondsAfterFinished }}
ttlSecondsAfterFinished: {{ .Values.cronjob.job.ttlSecondsAfterFinished }}
{{- end }}
template:
  {{- include "ethereum-sync-tests.pod-template" . | nindent 2}}
{{- end }}
