# Command Reference

## Argo CD

- `argocd login <server>:30080`
- `argocd app list`
- `argocd app sync homelab-app`

## Kubernetes

- List all apps: `kubectl get application -n argocd`
- Get Full Sync Details: `kubectl get application cert-manager -n argocd -o jsonpath='{.status.operationState}'`

## Testing a Helm chart change BEFORE pushing

Run from inside the actual chart folder (e.g. k8s-apps/cert-manager/)

- `helm dependency update`
- `helm template <release-name> . -n <namespace> | kubectl apply --dry-run=server -f -`

## Sealed Secrets

- Create the plain secret locally (never applied, never committed):
   `kubectl create secret generic <name> --namespace <target-namespace> --dry-run=client --from-literal=<key>='<value>' -o yaml plain.yaml`
- Seal it: kubeseal --format yaml < plain.yaml > sealed.yaml
- Delete the plaintext and commit sealed.yaml in place of the old secret file