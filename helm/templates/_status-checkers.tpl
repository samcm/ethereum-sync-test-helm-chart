{{- define "ethereum-sync-tests.status-checking" }}
{{- if eq .Values.global.ethereum.execution.client.name "geth" }}
{{ include "geth.sync-status-check-command" .Subcharts.geth }}
{{- end }}
{{- end }}