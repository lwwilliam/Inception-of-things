#!/bin/bash

cat <<EOF | kubectl patch configmap argocd-cm -n argocd --patch-file=/dev/stdin
data:
  accounts.lwilliam: apiKey, login
EOF

cat <<EOF | kubectl patch configmap argocd-rbac-cm -n argocd --patch-file=/dev/stdin
data:
  policy.csv: |
    g, lwilliam, role:admin
EOF

ADMIN_POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o jsonpath="{.items[0].metadata.name}")
DEFAULT_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd login localhost:8080 --username admin --password $DEFAULT_PASSWORD --insecure

# Set password for new user
argocd account update-password --account lwilliam --current-password $DEFAULT_PASSWORD --new-password Alpha!123