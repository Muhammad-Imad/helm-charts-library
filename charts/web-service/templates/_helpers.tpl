{{/*
Chart-local helpers for web-service.
Most logic is delegated to the `common` library chart; these are thin wrappers
so call sites can use short `web-service.*` names if preferred.
*/}}

{{- define "web-service.fullname" -}}
{{- include "common.fullname" . }}
{{- end }}

{{- define "web-service.labels" -}}
{{- include "common.labels" . }}
{{- end }}

{{- define "web-service.selectorLabels" -}}
{{- include "common.selectorLabels" . }}
{{- end }}
