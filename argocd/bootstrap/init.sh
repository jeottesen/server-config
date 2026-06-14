#!/bin/bash

# Set the working directory to always be argocd/bootstrap/
cd "$(dirname "${BASH_SOURCE[0]}")"

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl create namespace argocd

# Create sops + age secret
echo "Initializing sops + age secret"
kubectl create secret generic sops-age-key --namespace argocd --from-file=keys.txt=${HOME}/.config/sops/age/keys.txt

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd -n argocd argo/argo-cd -f values.yaml

# Create project
echo "Creating the main project..."
kubectl apply -f manifests/project.yaml

# Create the app of apps
echo "Creating the app of apps..."
kubectl apply -f manifests/application.yaml 

# kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
