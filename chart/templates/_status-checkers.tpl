{{- define "ethereum-sync-tests.status-checking-execution" }}
{{- if eq .Values.global.ethereum.execution.client.name "geth" }}
{{ include "geth.sync-status-check-command" .Subcharts.geth }}
{{- end }}

{{- end }}

{{- define "ethereum-sync-tests.status-checking-consensus" }}
{{- if eq .Values.global.ethereum.consensus.client.name "lighthouse" }}
{{ include "lighthouse.sync-status-check-command" .Subcharts.lighthouse }}
{{- end }}

{{- end }}