# Command Reference

## Argo CD

- `argocd login <server>:30080`
- `argocd app list`
- `argocd app sync homelab-app`
- `argocd app get netbird-operator`

## Kubernetes

- List all apps: `kubectl get application -n argocd`
- Get Full Sync Details: `kubectl describe application cert-manager -n argocd'`

## Helm

- `helm repo add <alias> <repo-url>   # only needed once per repo`
- `helm repo update`
- Find chart version: `helm search repo <alias>`
- For OCI charts: `helm show chart oci:<link>`

### Testing a Helm chart change BEFORE pushing

Run from inside the actual chart folder (e.g. k8s-apps/cert-manager/)

- `helm dependency update`
- `helm template <release-name> . -n <namespace> --include-crds | kubectl apply --dry-run=server -f -`

## Sealed Secrets

- Read the secret to an env var: `read -rs NB_API_KEY`
- Create the secret from the var and pipe it directly to a sealed file.

```bash
kubectl create secret generic netbird-mgmt-api-key \
  --namespace netbird --dry-run=client \
  --from-literal=NB_API_KEY="$NB_API_KEY" -o yaml \
  | kubeseal --format yaml > netbird-api-key-sealedsecret.yaml
```
