#!/bin/bash

k3d cluster create mycluster
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
echo "Waitiing for argocd binary file to be downloaded"
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

kubectl create namespace dev
kubectl apply -f ../conf/proj.yaml -n argocd
kubectl apply -f ../conf/app.yaml -n argocd

kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &

echo "Waiting for deployment/will42-playground to be created..."
until kubectl get deployment/will42-playground -n dev >/dev/null 2>&1; do
  sleep 5
done
kubectl rollout status deployment/will42-playground -n dev --timeout=300s
kubectl wait --for=condition=Ready pods --all -n dev --timeout=300s
kubectl port-forward svc/will42 -n dev 8888:8888 > /dev/null 2>&1 &

## Get ArgoCD Default password ##
# kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# remove the cluster
# sudo k3d cluster delete mycluster