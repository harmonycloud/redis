
{{- define "middlware.proxy" -}}
{{- if eq .Values.predixy.enableProxy true }}
  predixy:
    image: predixy:{{ .Values.image.predixyImageTag }}
    exporterImage: predixy-exporter:{{ .Values.image.predixyExporterImageTag }}
    affinity:
      {{- if eq (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) false }}
      {{- if eq .Values.podAntiAffinity "hard"}}
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
                - key: app
                  operator: In
                  values:
                    - {{ include "redis.fullname" . }}
            topologyKey: {{ .Values.podAntiAffinityTopologKey }}
      {{- else if eq .Values.podAntiAffinity "soft"}}
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              topologyKey: {{ .Values.podAntiAffinityTopologKey }}
              labelSelector:
                matchExpressions:
                  - key: app
                    operator: In
                    values:
                      - {{ include "redis.fullname" . }}
      {{- end }}
      {{- end }}
      {{- if eq (empty .Values.redis.nodeAffinity) true }}
      {{- with .Values.nodeAffinity }}
      nodeAffinity:
      {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- else }}
      nodeAffinity:
      {{- toYaml .Values.redis.nodeAffinity | nindent 8 }}
      {{- end }}
    {{- if eq (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) true }}
    topologySpreadConstraints:
    {{- if ne .Values.podAntiAffinityTopologKey "kubernetes.io/hostname"}}
      - maxSkew: 1
        topologyKey: {{ .Values.podAntiAffinityTopologKey | default "" }}
        {{- include "middlware.proxy.whenUnsatisfiable" . | indent 8 }}
        labelSelector:
          matchLabels:
            app: {{ include "redis.fullname" . }}
            component: {{ include "redis.fullname" . }}-predixy
    {{- end }}
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        {{- include "middlware.proxy.whenUnsatisfiable" . | indent 8}}
        labelSelector:
          matchLabels:
            app: {{ include "redis.fullname" . }}
            component: {{ include "redis.fullname" . }}-predixy
    {{- end }}
    {{- with .Values.tolerations }}
    tolerations:
      {{- toYaml . | nindent 6 }}
    {{- end}}
    {{- toYaml .Values.predixy | nindent 4 }}
    {{- if .Values.predixy.securityContext }}
    securityContext:
      runAsUser: {{ .Values.predixy.securityContext.runAsUser | default 0 }}
      runAsGroup: {{ .Values.predixy.securityContext.runAsGroup | default 0 }}
      fsGroup: 0
    {{- end }}
{{- end }}
{{- end }}

