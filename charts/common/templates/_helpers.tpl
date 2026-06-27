{{/*
common library chart — reusable named templates.

Usage from a consuming chart:

  {{ include "common.labels" . }}
  {{ include "common.selectorLabels" . }}
  {{- include "common.container.image" . }}

All helpers are namespaced under `common.*` so they never collide with
chart-local templates.
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
Truncated at 63 chars because some Kubernetes name fields are limited to this
(DNS naming spec). If release name contains chart name it is used as a full name.
*/}}
{{- define "common.fullname" -}}
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
Chart name and version as used by the chart label.
*/}}
{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels — recommended Kubernetes labels plus any user-supplied
`commonLabels` from values.
*/}}
{{- define "common.labels" -}}
helm.sh/chart: {{ include "common.chart" . }}
{{ include "common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Values.partOf | default (include "common.name" .) }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels — the minimal stable set used in matchLabels and pod template
labels. These MUST be immutable for the life of a Deployment.
*/}}
{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common annotations passed through from `.Values.commonAnnotations`.
*/}}
{{- define "common.annotations" -}}
{{- with .Values.commonAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Name of the service account to use.
*/}}
{{- define "common.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Container image reference. Honours an optional global registry override and
defaults the tag to the chart appVersion when not pinned in values.

  image: ghcr.io/acme/web:1.4.2
*/}}
{{- define "common.container.image" -}}
{{- $registry := .Values.image.registry | default ((.Values.global).imageRegistry) -}}
{{- $repository := required "image.repository is required" .Values.image.repository -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion | default "latest" -}}
{{- if $registry }}
image: {{ printf "%s/%s:%s" $registry $repository $tag | quote }}
{{- else }}
image: {{ printf "%s:%s" $repository $tag | quote }}
{{- end }}
imagePullPolicy: {{ .Values.image.pullPolicy | default "IfNotPresent" }}
{{- end }}

{{/*
imagePullSecrets block. Supports a global list and a chart-local list.
*/}}
{{- define "common.imagePullSecrets" -}}
{{- $secrets := concat (.Values.imagePullSecrets | default list) (((.Values.global).imagePullSecrets) | default list) -}}
{{- if $secrets }}
imagePullSecrets:
{{- range $secrets }}
  - name: {{ .name | default . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Render an env list from `.Values.env` (a map) plus `.Values.envFrom`.
env is rendered as a stable, sorted list of name/value pairs.
*/}}
{{- define "common.env" -}}
{{- if .Values.env }}
env:
{{- range $k, $v := .Values.env }}
  - name: {{ $k | quote }}
    value: {{ $v | quote }}
{{- end }}
{{- end }}
{{- with .Values.envFrom }}
envFrom:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
Resource requests/limits passthrough.
*/}}
{{- define "common.resources" -}}
{{- with .Values.resources }}
resources:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
Liveness and readiness probes. Renders only the probes that are enabled.
Expects `.Values.probes.liveness` / `.Values.probes.readiness` /
`.Values.probes.startup` blocks (each may set `enabled: false`).
*/}}
{{- define "common.probes" -}}
{{- with .Values.probes }}
{{- if and .liveness .liveness.enabled }}
livenessProbe:
{{ toYaml (omit .liveness "enabled") | indent 2 }}
{{- end }}
{{- if and .readiness .readiness.enabled }}
readinessProbe:
{{ toYaml (omit .readiness "enabled") | indent 2 }}
{{- end }}
{{- if and .startup .startup.enabled }}
startupProbe:
{{ toYaml (omit .startup "enabled") | indent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Pod-level security context.
*/}}
{{- define "common.podSecurityContext" -}}
{{- with .Values.podSecurityContext }}
securityContext:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
Container-level security context.
*/}}
{{- define "common.securityContext" -}}
{{- with .Values.securityContext }}
securityContext:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
Scheduling helpers: nodeSelector, affinity, tolerations, topologySpreadConstraints.
*/}}
{{- define "common.scheduling" -}}
{{- with .Values.nodeSelector }}
nodeSelector:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.topologySpreadConstraints }}
topologySpreadConstraints:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}
