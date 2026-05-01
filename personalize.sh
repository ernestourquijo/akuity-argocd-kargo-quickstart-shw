#!/bin/bash

echo -n "Enter GitHub username/org: "
read username

ghcr_username=$(echo "$username" | tr '[:upper:]' '[:lower:]')

# Replace GitHub org in all repo URLs
find . -type f -name '*.yaml' -exec sed -E -i '' s#https://github.com/[-_a-zA-Z0-9]+/akuity-argocd-kargo-quickstart#https://github.com/${username}/akuity-argocd-kargo-quickstart#g {} +
# Replace GHCR org for image references
find . -type f -name '*.yaml' -exec sed -E -i '' s#ghcr.io/[-_a-zA-Z0-9]+#ghcr.io/${ghcr_username}#g {} +

echo "Enter Argo CD destination name or server where applications will be deployed (e.g. in-cluster, https://kubernetes.default.svc)"
echo -n "Destination: "
read destination

if [[ $destination == https:* ]]; then
  sed -i.bak -E "s@^        (# )?server:.*@        server: ${destination}@g" argocd/appset.yaml
  sed -i.bak -E "s@^        (# )?name:.*@        # name: REPLACEME@g" argocd/appset.yaml
else
  sed -i.bak -E "s@^        (# )?name:.*@        name: ${destination}@g" argocd/appset.yaml
  sed -i.bak -E "s@^        (# )?server:.*@        # server: https://REPLACEME@g" argocd/appset.yaml
fi
rm -f argocd/appset.yaml.bak
