# Local Kubernetes Cluster

Colima k3s cluster with Traefik Gateway API, trusted TLS, and wildcard DNS. Bootstrapped automatically on macOS by the dotfiles installer.

## Quick Reference

| Item | Value |
|------|-------|
| Bootstrap script | `colima/colima-up.sh` (called by `install.sh`) |
| Re-run (idempotent) | `$DOTFILES_PATH/colima/colima-up.sh` |
| CLI help | `tgdots help colima` |
| HTTPS port | `8443` |
| HTTP port | `8080` (redirects to HTTPS) |
| TLD | `k8s.local` |
| URL pattern | `https://<namespace>-<service>.k8s.local:8443` |
| Gateway name | `local-gateway` (namespace: `default`) |
| TLS secret | `local-tls` (namespace: `default`) |
| Wildcard listener | `https-wildcard` on `*.k8s.local` |

## Deploying a Service

Create an HTTPRoute to expose a service at `https://<namespace>-<service>.k8s.local:8443`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: <service>
  namespace: <namespace>
spec:
  parentRefs:
  - name: local-gateway
    namespace: default
    sectionName: https-wildcard
  hostnames:
  - <namespace>-<service>.k8s.local
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: <service>
      port: <port>
```

No Ingress, TLS config, or DNS entries needed. The wildcard cert, DNS, and Gateway listener handle everything.

## How It Works

```
browser -> https://<ns>-<svc>.k8s.local:8443
             |
             +- DNS: /etc/resolver/k8s.local -> CoreDNS NodePort (30053) -> 127.0.0.1
             |
             +- TLS: Traefik terminates using local-tls secret (wildcard *.k8s.local)
             |
             +- Routing: Gateway listener -> HTTPRoute match -> Service -> Pod
```

## What the Bootstrap Creates

**Host:**
- `~/.local/share/colima-certs/` — local CA + TLS cert (openssl)
- macOS System Keychain — CA trust entry
- `/etc/resolver/k8s.local` — routes `*.k8s.local` DNS to in-cluster CoreDNS
- `~/Library/LaunchAgents/homebrew.mxcl.colima.plist` — brew service (auto-start)

**Cluster (kube-system):**
- `HelmChartConfig/traefik` — port remapping + Gateway API provider
- `ConfigMap/coredns-custom` — `*.k8s.local` -> 127.0.0.1
- `Service/coredns-external` — NodePort exposing CoreDNS UDP on 30053

**Cluster (default):**
- `Secret/local-tls` — TLS cert for localhost + `*.k8s.local`
- `Gateway/local-gateway` — HTTPS listeners (localhost + `*.k8s.local`)

## Key Constraints

- Gateway `local-gateway` lives in `default` namespace; HTTPRoutes can be in **any** namespace (`allowedRoutes.from: All`)
- TLS secret `local-tls` is in `default` namespace and shared by all listeners
- HTTP on 8080 auto-redirects to HTTPS on 8443
- `colima-up.sh` is fully idempotent — safe to re-run anytime
- Plist template uses `__HOME__` and `__HOMEBREW_PREFIX__` placeholders, rendered at runtime

## File Layout

```
colima/
  colima-up.sh                     — bootstrap script (executable)
  homebrew.mxcl.colima.plist       — launchd plist template
  AGENTS.md                        — this file
  manifests/
    coredns-custom.yaml            — CoreDNS wildcard config
    coredns-external.yaml          — CoreDNS NodePort service
    gateway.yaml                   — Gateway resource (+ commented HTTPRoute example)
    traefik-config.yaml            — Traefik HelmChartConfig
```
