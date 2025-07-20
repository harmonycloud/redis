{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "redis.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "redis.fullname" -}}
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
{{- define "redis.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "redis.labels" -}}
helm.sh/chart: {{ include "redis.chart" . }}
{{ include "redis.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "redis.selectorLabels" -}}
app.kubernetes.io/name: {{ include "redis.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "redis.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "redis.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "redis.cal.memory" -}}
    {{- $memoryRaw := index . 0 }}
    {{- $target := index . 1 }}

    {{- $maxmemory := 0}}
    {{- $hardLimit := 0}}
    {{- $softLimit := 0}}

    {{- $memory := regexFind "[0-9]*[.]*[0-9]*" $memoryRaw }}
    {{- $memoryB := 0 }}

    {{- if contains "." $memory }}
        {{- $memoryLs := regexSplit "\\." ($memory | toString) -1 }}
        {{- $memoryInt := index $memoryLs 0 }}
        {{- $memoryDecimal := index $memoryLs 1 }}
        {{- $memoryDecimalLen := len $memoryDecimal }}
        {{- $memoryDecimalDigit := 1 }}
        {{- range untilStep 0 $memoryDecimalLen 1 }}
            {{- $memoryDecimalDigit = mul $memoryDecimalDigit 10 }}
        {{- end }}
        {{- if contains "GI" (upper $memoryRaw) }}
            {{- $memoryB = add (mul ($memoryInt | int) 1024 1024 1024) (div (mul ($memoryDecimal | int) 1024 1024 1024) $memoryDecimalDigit) }}
        {{- else if contains "G" (upper $memoryRaw) }}
            {{- $memoryB = add (mul ($memoryInt | int) 1000 1000 1000) (div (mul ($memoryDecimal | int) 1000 1000 1000) $memoryDecimalDigit) }}
        {{- else if contains "MI" (upper $memoryRaw) }}
            {{- $memoryB = add (mul ($memoryInt | int) 1024 1024) (div (mul ($memoryDecimal | int) 1024 1024) $memoryDecimalDigit) }}
        {{- else if contains "M" (upper $memoryRaw) }}
            {{- $memoryB = add (mul ($memoryInt | int) 1000 1000) (div (mul ($memoryDecimal | int) 1000 1000) $memoryDecimalDigit) }}
        {{- end }}
    {{- else }}
        {{- if contains "GI" (upper $memoryRaw) }}
            {{- $memoryB = mul $memory 1024 1024 1024 }}
        {{- else if contains "G" (upper $memoryRaw) }}
            {{- $memoryB = mul $memory 1000 1000 1000 }}
        {{- else if contains "MI" (upper $memoryRaw) }}
            {{- $memoryB = mul $memory 1024 1024 }}
        {{- else if contains "M" (upper $memoryRaw) }}
            {{- $memoryB = mul $memory 1000 1000 }}
        {{- end }}
    {{- end }}

    {{- $memory = div (div $memoryB 1024) 1024 }}
    {{- $maxmemory = div (mul $memory 4) 5 }}
    {{- $hardLimit = div (mul $memory 4) 5 }}
    {{- $softLimit = div (mul $memory 2) 5 }}

    {{- if eq $target "max" }}
        {{- printf "%dmb" $maxmemory }}
    {{- else if eq $target "hard" }}
        {{- printf "%dmb" $hardLimit }}
    {{- else if eq $target "soft" }}
        {{- printf "%dmb" $softLimit }}
    {{- end }}
{{- end -}}


{{/*
Get Redis max memory usage with mb
*/}}
{{- define "redis.maxMemory" -}}
{{- if .Values.args.maxmemory }}
    {{- .Values.args.maxmemory }}
{{- else }}
    {{- include "redis.cal.memory" (list .Values.redis.resources.limits.memory "max") }}
{{- end }}
{{- end -}}


{{/*
Get Redis outputbuff.slave.hard limit
*/}}
{{- define "redis.outputbuff.slave.hard" -}}
{{- if .Values.args.maxmemory }}
    {{- include "redis.cal.memory" (list .Values.args.maxmemory "hard") }}
{{- else }}
    {{- include "redis.cal.memory" (list .Values.redis.resources.limits.memory "hard") }}
{{- end }}
{{- end -}}

{{/*
Get Redis outputbuff.slave.soft limit
*/}}
{{- define "redis.outputbuff.slave.soft" -}}
{{- if .Values.args.maxmemory }}
    {{- include "redis.cal.memory" (list .Values.args.maxmemory "soft") }}
{{- else }}
    {{- include "redis.cal.memory" (list .Values.redis.resources.limits.memory "soft") }}
{{- end }}
{{- end -}}

{{/*
If a list map has a specific value use that values, other wise use the defualt
*/}}
{{- define "helm.function.ifListMapHasValue" -}}
  {{- $list := index . 0 -}}
  {{- $Key := index . 1 -}}
  {{- $targetValue := index . 2 -}}
  {{- $defaultValue := index . 3 -}}

  {{- $value := $defaultValue -}}

  {{- range $list -}}
    {{- if eq (index . $Key) $targetValue -}}
      {{- $value = $targetValue -}}
    {{- end -}}
  {{- end -}}
  {{- $value -}}
{{- end -}}
