{{- define "ethereum-sync-tests.status-checking-execution" }}
{{- if eq .Values.global.ethereum.execution.client.name "geth" }}
{{ include "geth.sync-status-check-command" .Subcharts.geth }}
{{- end }}
{{- if eq .Values.global.ethereum.execution.client.name "nethermind" }}
{{ include "nethermind.sync-status-check-command" .Subcharts.nethermind }}
{{- end }}
{{- if eq .Values.global.ethereum.execution.client.name "besu" }}
{{ include "besu.sync-status-check-command" .Subcharts.besu }}
{{- end }}

{{- end }}

{{- define "ethereum-sync-tests.status-checking-consensus" }}
{{- if eq .Values.global.ethereum.consensus.client.name "lighthouse" }}
{{ include "lighthouse.sync-status-check-command" .Subcharts.lighthouse }}
{{- end }}
{{- if eq .Values.global.ethereum.consensus.client.name "prysm" }}
{{ include "prysm.sync-status-check-command" .Subcharts.prysm }}
{{- end }}
{{- if eq .Values.global.ethereum.consensus.client.name "teku" }}
{{ include "teku.sync-status-check-command" .Subcharts.teku }}
{{- end }}
{{- if eq .Values.global.ethereum.consensus.client.name "nimbus" }}
{{ include "nimbus.sync-status-check-command" .Subcharts.nimbus }}
{{- end }}

{{- end }}