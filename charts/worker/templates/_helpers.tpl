{{/*
Chart-local helpers for worker. Logic is delegated to the `common` library.
*/}}

{{- define "worker.fullname" -}}
{{- include "common.fullname" . }}
{{- end }}

{{- define "worker.labels" -}}
{{- include "common.labels" . }}
{{- end }}

{{- define "worker.selectorLabels" -}}
{{- include "common.selectorLabels" . }}
{{- end }}
