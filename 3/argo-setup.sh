#!/bin/bash

k3d cluster create mycluster
sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

sudo kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

sudo kubectl port-forward svc/argocd-server -n argocd 8080:443
