{{- define "helpers.ENV" -}}
{{- if eq .Values.environment "stg" -}}
    {{- print "staging" -}}
{{- else if  eq .Values.environment "prd" -}}    
    {{- print "prod" -}}
{{- else -}}
    {{- print .Values.environment -}}
{{- end -}}
{{- end -}}

{{- define "helpers.SERVICE_ACCOUNT" -}}


{{- if and (eq .Values.tenant "b6") (eq (include "helpers.ENV" . ) "staging") -}}
    {{- print "config-connector-sa@fusionrm-b6-staging-1947553014.iam.gserviceaccount.com" -}}
{{- else if eq .Values.product "data" -}}
    {{- printf "config-connector-sa@fusionrm-%s-data-%s.iam.gserviceaccount.com" .Values.tenant (include "helpers.ENV" . ) -}}
{{- else -}}
    {{- printf "config-connector-sa@fusionrm-%s-%s.iam.gserviceaccount.com" .Values.tenant (include "helpers.ENV" . ) -}}
{{- end -}}
{{- end -}}
