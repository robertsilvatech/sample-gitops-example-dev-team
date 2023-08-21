{{- define "chart.env" }}
env:
    {{- range $key, $val := .Values.env }}
    {{- if eq $key "GF_DATABASE_USER" }}
    - name: GF_DATABASE_USER
      valueFrom:
        secretKeyRef:
          name: {{ $.Release.Name }}
          key: GF_DATABASE_USER 
          optional: false
    {{- else if eq $key "GF_DATABASE_PASSWORD" }}
    - name: GF_DATABASE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ $.Release.Name }}
          key: GF_DATABASE_PASSWORD
          optional: false
    {{- else }}
    - name: {{ $key }}
      value: {{ $val | quote }}
    {{- end }}
    {{- end }}
{{- end }}
