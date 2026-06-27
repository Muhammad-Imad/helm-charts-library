# web-service

An opinionated application chart for a **stateless HTTP microservice**. It builds
on the [`common`](../common) library chart for labels, image, probes, resources
and security context, then layers the resources a typical request-serving
service needs.

## Resources rendered

| Resource | Condition |
| -------- | --------- |
| Deployment | always |
| Service (ClusterIP) | always |
| ServiceAccount | `serviceAccount.create` |
| ConfigMap | `config.enabled` |
| Ingress | `ingress.enabled` |
| HorizontalPodAutoscaler | `autoscaling.enabled` |
| PodDisruptionBudget | `podDisruptionBudget.enabled` |
| NetworkPolicy | `networkPolicy.enabled` |
| ExternalSecret | `externalSecret.enabled` |

## Install

```bash
helm repo add acme https://acme.github.io/helm-charts-library
helm install my-web acme/web-service \
  --set image.repository=ghcr.io/acme/web \
  --set image.tag=1.4.2
```

## Key values

| Key | Default | Description |
| --- | ------- | ----------- |
| `replicaCount` | `2` | Replicas when autoscaling is off. |
| `image.registry` | `ghcr.io/acme` | Registry prefix. |
| `image.repository` | `web` | Image repository (required). |
| `image.tag` | `""` | Defaults to chart `appVersion`. |
| `service.port` | `80` | Service port. |
| `service.targetPort` | `8080` | Container port (named `http`). |
| `ingress.enabled` | `false` | Create an Ingress. |
| `autoscaling.enabled` | `true` | Create an HPA. |
| `autoscaling.maxReplicas` | `10` | HPA upper bound. |
| `podDisruptionBudget.enabled` | `true` | Create a PDB. |
| `networkPolicy.enabled` | `false` | Restrict ingress traffic. |
| `externalSecret.enabled` | `false` | Sync secrets via ESO. |
| `securityContext` | hardened | Non-root, read-only rootfs, drop ALL caps. |

See [`values.yaml`](./values.yaml) for the complete, commented set. Inputs are
validated at install time against [`values.schema.json`](./values.schema.json).

## Security defaults

The chart ships hardened defaults: pods run as non-root, with a read-only root
filesystem, `RuntimeDefault` seccomp, dropped Linux capabilities, and a writable
`/tmp` emptyDir so the read-only rootfs doesn't break common runtimes.
