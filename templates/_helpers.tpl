{{/*
Get the Redis password secret
*/}}
{{- define "ds.redis.secretName" -}}
{{- if or .Values.connections.redisPassword .Values.connections.redisNoPass -}}
    {{- printf "%s-redis" .Release.Name -}}
{{- else if .Values.connections.redisExistingSecret -}}
    {{- printf "%s" (tpl .Values.connections.redisExistingSecret $) -}}
{{- end -}}
{{- end -}}

{{/*
Get the redis password
*/}}
{{- define "ds.redis.pass" -}}
{{- $redisSecret := include "ds.redis.secretName" . }}
{{- $secretKey := (lookup "v1" "Secret" .Release.Namespace $redisSecret).data }}
{{- $keyValue := (get $secretKey .Values.connections.redisSecretKeyName) | b64dec }}
{{- if .Values.connections.redisPassword -}}
    {{- printf "%s" .Values.connections.redisPassword -}}
{{- else if $keyValue -}}
    {{- printf "%s" $keyValue -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created for Redis
*/}}
{{- define "ds.redis.createSecret" -}}
{{- if or .Values.connections.redisPassword .Values.connections.redisNoPass (not .Values.connections.redisExistingSecret) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return Redis password
*/}}
{{- define "ds.redis.password" -}}
{{- if not (empty .Values.connections.redisPassword) }}
    {{- .Values.connections.redisPassword }}
{{- else if .Values.connections.redisNoPass }}
    {{- printf "" }}
{{- else }}
    {{- required "A Redis Password is required!" .Values.connections.redisPassword }}
{{- end }}
{{- end -}}

{{/*
Get the Redis Sentinel password secret
*/}}
{{- define "ds.redis.sentinel.secretName" -}}
{{- if or .Values.connections.redisSentinelPassword .Values.connections.redisSentinelNoPass -}}
    {{- printf "%s-redis-sentinel" .Release.Name -}}
{{- else if .Values.connections.redisSentinelExistingSecret -}}
    {{- printf "%s" (tpl .Values.connections.redisSentinelExistingSecret $) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created for Redis Sentinel
*/}}
{{- define "ds.redis.sentinel.createSecret" -}}
{{- if or .Values.connections.redisSentinelPassword .Values.connections.redisSentinelNoPass (not .Values.connections.redisSentinelExistingSecret) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Get the Redis Sentinel password
*/}}
{{- define "ds.redis.sentinel.pass" -}}
{{- $redisSecret := include "ds.redis.sentinel.secretName" . }}
{{- $secretKey := (lookup "v1" "Secret" .Release.Namespace $redisSecret).data }}
{{- $keyValue := (get $secretKey .Values.connections.redisSentinelSecretKeyName) | b64dec }}
{{- if .Values.connections.redisSentinelPassword -}}
    {{- printf "%s" .Values.connections.redisSentinelPassword -}}
{{- else if $keyValue -}}
    {{- printf "%s" $keyValue -}}
{{- end -}}
{{- end -}}

{{/*
Return Redis Sentinel password
*/}}
{{- define "ds.redis.sentinel.password" -}}
{{- if not (empty .Values.connections.redisSentinelPassword) }}
    {{- .Values.connections.redisSentinelPassword }}
{{- else if .Values.connections.redisSentinelNoPass }}
    {{- printf "" }}
{{- else }}
    {{- required "A Redis Sentinel Password is required!" .Values.connections.redisSentinelPassword }}
{{- end }}
{{- end -}}

{{/*
Get the info auth password secret
*/}}
{{- define "ds.info.secretName" -}}
{{- if .Values.documentserver.proxy.infoAllowedExistingSecret -}}
    {{- printf "%s" (tpl .Values.documentserver.proxy.infoAllowedExistingSecret $) -}}
{{- else if .Values.documentserver.proxy.infoAllowedUser -}}
    {{- printf "%s-info-auth" .Release.Name -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created for info auth
*/}}
{{- define "ds.info.createSecret" -}}
{{- if and .Values.documentserver.proxy.infoAllowedUser (not .Values.documentserver.proxy.infoAllowedExistingSecret) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Get the PVC name
*/}}
{{- define "ds.pvc.name" -}}
{{- if .Values.persistence.existingClaim -}}
    {{- printf "%s" (tpl .Values.persistence.existingClaim $) -}}
{{- else }}
    {{- printf "ds-service-files" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a pvc object for ds-service-files should be created
*/}}
{{- define "ds.pvc.create" -}}
{{- if empty .Values.persistence.existingClaim }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Get the license name
*/}}
{{- define "ds.license.secretName" -}}
{{- if .Values.license.existingSecret -}}
    {{- printf "%s" (tpl .Values.license.existingSecret $) -}}
{{- else }}
    {{- printf "license" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created for license
*/}}
{{- define "ds.license.createSecret" -}}
{{- if and (empty .Values.license.existingSecret) (empty .Values.license.existingClaim) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Get the jwt name
*/}}
{{- define "ds.jwt.secretName" -}}
{{- if .Values.jwt.existingSecret -}}
    {{- printf "%s" (tpl .Values.jwt.existingSecret $) -}}
{{- else }}
    {{- printf "jwt" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created for jwt
*/}}
{{- define "ds.jwt.createSecret" -}}
{{- if empty .Values.jwt.existingSecret }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Get the service name for ds
*/}}
{{- define "ds.svc.name" -}}
{{- if not (empty .Values.customBalancer.service.existing) }}
    {{- printf "%s" (tpl .Values.customBalancer.service.existing $) -}}
{{- else if empty .Values.customBalancer.service.existing }}
    {{- printf "docs-balancer" -}}
{{- else }}
    {{- printf "documentserver" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a balancer service object should be created for ds
*/}}
{{- define "balancer.svc.create" -}}
{{- if empty .Values.customBalancer.service.existing }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return balancer shutdown timer
*/}}
{{- define "balancer.shutdown.timer" -}}
{{- if le (int .Values.customBalancer.terminationGracePeriodSeconds) 60 -}}
    {{- printf "70" -}}
{{- else }}
    {{- printf "%s" .Values.customBalancer.terminationGracePeriodSeconds -}}
{{- end -}}
{{- end -}}

{{/*
Get the ds labels
*/}}
{{- define "ds.labels.commonLabels" -}}
{{- range $key, $value := .Values.commonLabels }}
{{ $key }}: {{ tpl $value $ }}
{{- end }}
{{- end -}}

{{/*
Get the ds annotations
*/}}
{{- define "ds.annotations.commonAnnotations" -}}
{{- $annotations := toYaml .keyName }}
{{- if contains "{{" $annotations }}
    {{- tpl $annotations .context }}
{{- else }}
    {{- $annotations }}
{{- end }}
{{- end -}}

{{/*
Get the update strategy type for ds
*/}}
{{- define "ds.update.strategyType" -}}
{{- if eq .type "RollingUpdate" -}}
    {{- toYaml . | nindent 4 -}}
{{- else -}}
    {{- omit . "rollingUpdate" | toYaml | nindent 4 -}}
{{- end -}}
{{- end -}}

{{/*
Get the ds Service Account name
*/}}
{{- define "ds.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default .Release.Name .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Get the ds Namespace
*/}}
{{- define "ds.namespace" -}}
{{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
{{- else -}}
    {{- .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{/*
Get the ds Grafana Namespace
*/}}
{{- define "ds.grafana.namespace" -}}
{{- if .Values.grafana.namespace -}}
    {{- .Values.grafana.namespace -}}
{{- else if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
{{- else -}}
    {{- .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{/*
Get the ds virtual path
*/}}
{{- define "ds.ingress.path" -}}
{{- if eq .Values.ingress.path "/" -}}
    {{- printf "/" -}}
{{- else }}
    {{- printf "%s(/|$)(.*)" .Values.ingress.path -}}
{{- end -}}
{{- end -}}

{{/*
Get ds url for example
*/}}
{{- define "ds.example.dsUrl" -}}
{{- if and (ne .Values.ingress.path "/") (eq .Values.example.dsUrl "/") -}}
    {{- printf "%s/" (tpl .Values.ingress.path $) -}}
{{- else }}
    {{- printf "%s" (tpl .Values.example.dsUrl $) -}}
{{- end -}}
{{- end -}}

{{/*
Get the Secret value
*/}}
{{- define "ds.secrets.lookup" -}}
{{- $context := index . 0 -}}
{{- $existValue := index . 1 -}}
{{- $getSecretName := index . 2 -}}
{{- $getSecretKey := index . 3 -}}
{{- if not $existValue }}
    {{- $secret_lookup := (lookup "v1" "Secret" $context.Release.Namespace $getSecretName).data }}
    {{- $getSecretValue := (get $secret_lookup $getSecretKey) | b64dec }}
    {{- if $getSecretValue -}}
        {{- printf "%s" $getSecretValue -}}
    {{- else -}}
        {{- printf "%s" (randAlpha 16) -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s" $existValue -}}
{{- end -}}
{{- end -}}
