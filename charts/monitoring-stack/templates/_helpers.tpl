{{/*
Expand the name of the chart.
*/}}
{{- define "monitoring-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "monitoring-stack.fullname" -}}
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
Common labels
*/}}
{{- define "monitoring-stack.labels" -}}
helm.sh/chart: {{ include "monitoring-stack.chart" . }}
{{ include "monitoring-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "monitoring-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "monitoring-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Chart name and version
*/}}
{{- define "monitoring-stack.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/*
Create the name of the service account
*/}}
{{- define "monitoring-stack.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
  {{- if .Values.serviceAccount.name }}
    {{- .Values.serviceAccount.name }}
  {{- else }}
    {{- printf "%s-sa" .Release.Name }}
  {{- end }}
{{- else }}
  default
{{- end }}
{{- end }}
