
{{- define "middlware.whenUnsatisfiable" }}
{{- if eq .Values.podAntiAffinity "hard"}}
whenUnsatisfiable: DoNotSchedule
{{- else if eq .Values.podAntiAffinity "soft"}}
whenUnsatisfiable: ScheduleAnyway
{{- end }}
{{- end }}


{{- define "middlware.proxy.whenUnsatisfiable" }}
{{- if empty .Values.predixy.podAntiAffinity}}
{{- include "middlware.whenUnsatisfiable" . }}
{{- else if eq .Values.predixy.podAntiAffinity "hard"}}
whenUnsatisfiable: DoNotSchedule
{{- else if eq .Values.predixy.podAntiAffinity "soft"}}
whenUnsatisfiable: ScheduleAnyway
{{- else if eq .Values.predixy.podAntiAffinity ""}}
{{- include "middlware.whenUnsatisfiable" . }}
{{- end }}
{{- end }}


{{- define "middlware.sentinel.whenUnsatisfiable" }}
{{- if empty .Values.sentinel.podAntiAffinity}}
{{- include "middlware.whenUnsatisfiable" . }}
{{- else if eq .Values.sentinel.podAntiAffinity "hard"}}
whenUnsatisfiable: DoNotSchedule
{{- else if eq .Values.sentinel.podAntiAffinity "soft"}}
whenUnsatisfiable: ScheduleAnyway
{{- else if eq .Values.sentinel.podAntiAffinity ""}}
{{- include "middlware.whenUnsatisfiable" . }}
{{- end }}
{{- end }}

