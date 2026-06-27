# common

A Helm **library chart** (`type: library`) that exposes a set of reusable named
templates ("helpers"). It renders **no** Kubernetes objects on its own — instead,
application charts depend on it and `include` its helpers to stay DRY and
consistent.

## Why a library chart?

Without a shared library, every application chart re-implements the same
`_helpers.tpl` boilerplate (labels, fullname, image string, probes…). That drift
is exactly where subtle production differences creep in. `common` centralizes
that logic so dozens of services share one tested implementation.

## Usage

Add it as a dependency in your chart's `Chart.yaml`:

```yaml
dependencies:
  - name: common
    version: "0.3.x"
    repository: "https://acme.github.io/helm-charts-library"
```

Then run `helm dependency update` and call the helpers from your templates:

```yaml
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
  template:
    spec:
      serviceAccountName: {{ include "common.serviceAccountName" . }}
      {{- include "common.imagePullSecrets" . | nindent 6 }}
      containers:
        - name: {{ .Chart.Name }}
          {{- include "common.container.image" . | nindent 10 }}
          {{- include "common.env" . | nindent 10 }}
          {{- include "common.resources" . | nindent 10 }}
          {{- include "common.probes" . | nindent 10 }}
          {{- include "common.securityContext" . | nindent 10 }}
```

## Available helpers

| Helper | Purpose |
| ------ | ------- |
| `common.name` | Chart name, honouring `nameOverride`. |
| `common.fullname` | Fully-qualified release name (≤ 63 chars). |
| `common.chart` | `name-version` chart label value. |
| `common.labels` | Recommended Kubernetes labels + `commonLabels`. |
| `common.selectorLabels` | Immutable selector label subset. |
| `common.annotations` | Pass-through of `commonAnnotations`. |
| `common.serviceAccountName` | Resolves the SA name to use. |
| `common.container.image` | `image:` + `imagePullPolicy:` lines. |
| `common.imagePullSecrets` | Merged global + local pull secrets. |
| `common.env` | `env:`/`envFrom:` from a values map. |
| `common.resources` | `resources:` passthrough. |
| `common.probes` | liveness/readiness/startup probes (each toggleable). |
| `common.podSecurityContext` | Pod-level `securityContext:`. |
| `common.securityContext` | Container-level `securityContext:`. |
| `common.scheduling` | nodeSelector/affinity/tolerations/topologySpread. |

## Notes

- All helpers are namespaced under `common.*` to avoid collisions.
- Helpers emit indentation-friendly YAML; use `nindent` at the call site.
- Library charts are never installed directly (`helm install common` is a no-op).
