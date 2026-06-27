# worker

An application chart for a **queue / async worker**. Unlike `web-service`, it
renders no Service or Ingress — a worker pulls jobs rather than serving requests.
It depends on the [`common`](../common) library chart for shared helpers.

## Resources rendered

| Resource | Condition |
| -------- | --------- |
| Deployment | always |
| ServiceAccount | `serviceAccount.create` |
| KEDA ScaledObject | `keda.enabled` |
| HorizontalPodAutoscaler | `autoscaling.enabled` and **not** `keda.enabled` |
| PodDisruptionBudget | `podDisruptionBudget.enabled` |

## Scaling model

Workers scale on **queue depth**, not CPU. Two mutually exclusive options:

- **KEDA (default)** — a `ScaledObject` scales the Deployment from the queue
  metric, including **scale-to-zero** (`minReplicaCount: 0`). Requires
  [KEDA](https://keda.sh) installed in the cluster.
- **HPA on a custom metric** — set `keda.enabled=false` and
  `autoscaling.enabled=true` to use a plain v2 HPA on a Pods metric served by a
  metrics adapter (e.g. Prometheus Adapter).

If both are disabled, a static `replicaCount` is used.

## Install

```bash
helm repo add acme https://acme.github.io/helm-charts-library
helm install ingest acme/worker \
  --set image.repository=ghcr.io/acme/worker \
  --set image.tag=2.0.1 \
  --set env.QUEUE_NAME=ingest
```

## Key values

| Key | Default | Description |
| --- | ------- | ----------- |
| `image.repository` | `worker` | Image repository (required). |
| `keda.enabled` | `true` | Create a KEDA ScaledObject. |
| `keda.minReplicaCount` | `0` | Scale-to-zero floor. |
| `keda.maxReplicaCount` | `20` | Upper bound. |
| `keda.triggers` | SQS example | KEDA trigger list. |
| `autoscaling.enabled` | `false` | Fallback HPA (custom metric). |
| `podDisruptionBudget.enabled` | `true` | Create a PDB. |
| `terminationGracePeriodSeconds` | `60` | Drain time for in-flight jobs. |

See [`values.yaml`](./values.yaml) for the full, commented set. Inputs are
validated against [`values.schema.json`](./values.schema.json).
