# Command Reference

## Tofu

- `tofu init`
- `tofu plan`

### Export k8s and talos configs

- `tofu output -raw kubeconfig > ~/.kube/config`
- `tofu output -raw talosconfig > ~/.talos/config`

## Argo CD

### Commands

- `argocd login k8s-cp-01:30080`
- `argocd app list`
- `argocd app sync homelab-app`
- `argocd app get netbird-operator`

### Sync Wave

| wave | what goes there | apps |
| --- | --- | --- |
| `-99` | secrets foundation (provides the `SealedSecret` CRD) | sealed-secrets |
| `-50` | networking and load balancing | metallb (pool objects one wave later, `-49`, or as hooks in the chart) |
| `-40` | cluster-wide certificates | cert-manager |
| `-30` | ingress controllers | traefik |
| `-20` | operators that provide CRDs for other apps | arc-controller, netbird-operator |
| `-10` | apps that consume those CRDs | arc-runners |
| `0` (no annotation) | ordinary apps | whoami and anything new |


## Kubernetes

- List all apps: `kubectl get application -n argocd`
- Get Full Sync Details: `kubectl describe application cert-manager -n argocd'`
- Restart deployment: `kubectl rollout restart deployment netbird-operator -n netbird`
- Get Logs: `kubectl logs deploy/netbird-operator -n netbird -f`
- `kubectl get nodes`

## Talos

- `talosctl health -n k8s-cp-01`

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

### Backup

- `kubectl get secret -n kube-system   -l sealedsecrets.bitnami.com/sealed-secrets-key   -o yaml > sealed-secrets-key-backup.yaml`

### Restore

- Remove extra stuff: `yq 'del(.items[].metadata.uid, .items[].metadata.resourceVersion, .items[].metadata.creationTimestamp)' sealed-secrets-key-backup.yaml > sealed-secrets-key-restore.yaml`
- `kubectl apply -f sealed-secrets-key-restore.yaml`
- Verify: `kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key`

## Resticprofiles backup and restore

- `docker exec resticprofile resticprofile vaultwarden-b2.backup`
- `docker exec resticprofile resticprofile vaultwarden-garage.restore latest`
- `docker exec resticprofile resticprofile unifi-garage.ls latest`
