echo "=====Deploy KEDA VALUES.sh===="

cat >./deployment/keda/value.yaml <<EOF
image:
  keda:
    repository: ghcr.io/kedacore/keda
    # Allows people to override tag if they don't want to use the app version
    tag:
  metricsApiServer:
    repository: ghcr.io/kedacore/keda-metrics-apiserver
    # Allows people to override tag if they don't want to use the app version
    tag:
  pullPolicy: Always

crds:
  install: true

watchNamespace: ""

imagePullSecrets: []

operator:
  name: keda-operator
  replicaCount: 1
  # -- Affinity for pod scheduling https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/ for KEDA operator. Takes precedence over the `affinity` field
  affinity: {}
    # podAntiAffinity:
    #   requiredDuringSchedulingIgnoredDuringExecution:
    #   - labelSelector:
    #       matchExpressions:
    #       - key: app
    #         operator: In
    #         values:
    #         - keda-operator
    #     topologyKey: "kubernetes.io/hostname"

metricsServer:
  replicaCount: 1
  # use ClusterFirstWithHostNet if `useHostNetwork: true` https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy
  dnsPolicy: ClusterFirst
  useHostNetwork: false
  # -- Affinity for pod scheduling https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/ for Metrics API Server. Takes precedence over the `affinity` field
  affinity: {}
    # podAntiAffinity:
    #   requiredDuringSchedulingIgnoredDuringExecution:
    #   - labelSelector:
    #       matchExpressions:
    #       - key: app
    #         operator: In
    #         values:
    #         - keda-operator-metrics-apiserver
    #     topologyKey: "kubernetes.io/hostname"

upgradeStrategy:
  operator: {}
    # type: RollingUpdate
    # rollingUpdate:
    #   maxUnavailable: 1
    #   maxSurge: 1
  metricsApiServer: {}
    # type: RollingUpdate
    # rollingUpdate:
    #   maxUnavailable: 1
    #   maxSurge: 1

podDisruptionBudget: {}
  # operator:
  #   minAvailable: 1
  #   maxUnavailable: 1
  # metricServer:
  #   minAvailable: 1
  #   maxUnavailable: 1

# -- Custom labels to add into metadata
additionalLabels:
  {}
  # foo: bar

# -- Custom annotations to add into metadata
additionalAnnotations:
  {}
  # foo: bar

podAnnotations:
  keda: {}
  metricsAdapter: {}
podLabels:
  keda: {}
  metricsAdapter: {}

rbac:
  create: true

serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: keda-operator
  # Specifies whether a service account should automount API-Credentials
  automountServiceAccountToken: true
  # Annotations to add to the service account
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::${ACCOUNT_ID}:role/${IAM_KEDA_ROLE}

podIdentity:
  activeDirectory:
    # Set to the value of the Azure Active Directory Pod Identity
    # See https://keda.sh/docs/concepts/authentication/#azure-pod-identity
    # This will be set as a label on the KEDA Pod(s)
    identity: ""
  azureWorkload:
    # Set to true to enable Azure Workload Identity usage.
    # See https://keda.sh/docs/concepts/authentication/#azure-workload-identity
    # This will be set as a label on the KEDA service account.
    enabled: false
    # Set to the value of the Azure Active Directory Client and Tenant Ids
    # respectively. These will be set as annotations on the KEDA service account.
    clientId: ""
    tenantId: ""
    # Set to the value of the service account token expiration duration.
    # This will be set as an annotation on the KEDA service account.
    tokenExpiration: 3600
  aws:
    irsa:
      # Set to true to enable AWS IAM Roles for Service Accounts (IRSA).
      enabled: false
      # Sets the token audience for IRSA.
      # This will be set as an annotation on the KEDA service account.
      audience: "sts.amazonaws.com"
      # Set to the value of the ARN of an IAM role with a web identity provider.
      # This will be set as an annotation on the KEDA service account.
      roleArn: ""
      # Sets the use of an STS regional endpoint instead of global.
      # Recommended to use regional endpoint in almost all cases.
      # This will be set as an annotation on the KEDA service account.
      stsRegionalEndpoints: "true"
      # Set to the value of the service account token expiration duration.
      # This will be set as an annotation on the KEDA service account.
      tokenExpiration: 86400

# Set this if you are using an external scaler and want to communicate
# over TLS (recommended). This variable holds the name of the secret that
# will be mounted to the /grpccerts path on the Pod
grpcTLSCertsSecret: ""

# Set this if you are using HashiCorp Vault and want to communicate
# over TLS (recommended). This variable holds the name of the secret that
# will be mounted to the /vault path on the Pod
hashiCorpVaultTLS: ""

logging:
  operator:
    ## Logging level for KEDA Operator
    # allowed values: 'debug', 'info', 'error', or an integer value greater than 0, specified as string
    # default value: info
    level: info
    # allowed values: 'json' or 'console'
    # default value: console
    format: console
    ## Logging time encoding for KEDA Operator
    # allowed values are 'epoch', 'millis', 'nano', 'iso8601', 'rfc3339' or 'rfc3339nano'
    # default value: rfc3339
    timeEncoding: rfc3339
  metricServer:
    ## Logging level for Metrics Server
    # allowed values: '0' for info, '4' for debug, or an integer value greater than 0, specified as string
    # default value: 0
    level: 0

securityContext:
  operator:
    capabilities:
      drop:
      - ALL
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: true
    seccompProfile:
      type: RuntimeDefault
  metricServer:
    capabilities:
      drop:
      - ALL
    allowPrivilegeEscalation: false
    ## Metrics server needs to write the self-signed cert. See FAQ for discussion of options.
    # readOnlyRootFilesystem: true
    seccompProfile:
      type: RuntimeDefault

podSecurityContext:
  operator:
    runAsNonRoot: true
    runAsUser: 1001
    runAsGroup: 1001
    fsGroup: 1001
  metricServer:
    runAsNonRoot: true
    # runAsUser: 1000
    # runAsGroup: 1000
    # fsGroup: 1000

service:
  type: ClusterIP
  portHttp: 80
  portHttpTarget: 8080
  portHttps: 443
  portHttpsTarget: 6443

  annotations: {}

# We provides the default values that we describe in our docs:
# https://keda.sh/docs/latest/operate/cluster/
# If you want to specify the resources (or totally remove the defaults), change or comment the following
# lines, adjust them as necessary, or simply add the curly braces after 'operator' and/or 'metricServer'
# and remove/comment the default values
resources:
  operator:
    limits:
      cpu: 1
      memory: 1000Mi
    requests:
      cpu: 100m
      memory: 100Mi
  metricServer:
    limits:
      cpu: 1
      memory: 1000Mi
    requests:
      cpu: 100m
      memory: 100Mi

nodeSelector: {}

tolerations: []

# -- Pod Topology Constraints https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
topologySpreadConstraints: {}
  #operator: []
  #metricsServer: []

# -- Affinity for pod scheduling https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/ for both KEDA operator and Metrics API Server
affinity: {}
  # podAntiAffinity:
  #   requiredDuringSchedulingIgnoredDuringExecution:
  #   - labelSelector:
  #       matchExpressions:
  #       - key: app
  #         operator: In
  #         values:
  #         - keda-operator
  #         - keda-operator-metrics-apiserver
  #     topologyKey: "kubernetes.io/hostname"

## Optional priorityClassName for KEDA Operator and Metrics Adapter
priorityClassName: ""

## The default HTTP timeout in milliseconds that KEDA should use
## when making requests to external services. Removing this defaults to a
## reasonable default
http:
  timeout: 3000
  keepAlive:
    enabled: true

## Extra KEDA Operator and Metrics Adapter container arguments
extraArgs:
  keda: {}
  metricsAdapter: {}

## Extra environment variables that will be passed onto KEDA operator and metrics api service
env:
# - name: ENV_NAME
#   value: 'ENV-VALUE'

# Extra volumes and volume mounts for the deployment. Optional.
volumes:
  keda:
    extraVolumes: []
    extraVolumeMounts: []

  metricsApiServer:
    extraVolumes: []
    extraVolumeMounts: []

prometheus:
  metricServer:
    enabled: false
    port: 9022
    portName: metrics
    path: /metrics
    podMonitor:
      # Enables PodMonitor creation for the Prometheus Operator
      enabled: false
      interval:
      scrapeTimeout:
      namespace:
      additionalLabels: {}
      relabelings: []
  operator:
    enabled: false
    port: 8080
    podMonitor:
      # Enables PodMonitor creation for the Prometheus Operator
      enabled: false
      interval:
      scrapeTimeout:
      namespace:
      additionalLabels: {}
      relabelings: []
    prometheusRules:
      # Enables PrometheusRules creation for the Prometheus Operator
      enabled: false
      namespace:
      additionalLabels: {}
      alerts:
        []
        # - alert: KedaScalerErrors
        #   annotations:
        #     description: Keda scaledObject {{ $labels.scaledObject }} is experiencing errors with {{ $labels.scaler }} scaler
        #     summary: Keda Scaler {{ $labels.scaler }} Errors
        #   expr: sum by ( scaledObject , scaler) (rate(keda_metrics_adapter_scaler_errors[2m]))  > 0
        #   for: 2m
        #   labels:

permissions:
  metricServer:
    restrict:
      secret: false
  operator:
    restrict:
      secret: false
EOF
