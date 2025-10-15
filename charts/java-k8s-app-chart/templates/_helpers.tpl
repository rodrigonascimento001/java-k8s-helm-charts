{{/*
Return the name of the chart
*/}}
{{- define "java-k8s-app.name" -}}
{{ .Chart.Name }}
{{- end }}

{{/*
Return the fullname
*/}}
{{- define "java-k8s-app.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}
