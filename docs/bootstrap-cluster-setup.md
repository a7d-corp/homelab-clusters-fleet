# Bootstrapping the bootstrap cluster

## Create github deploy key for flux

```
flux create secret git flux-github-auth --url=ssh://git@github.com/a7d-corp/homelab-clusters-fleet --export > flux-github-auth.yaml
sops -e -i --output-type yaml flux-github-auth.yaml
```

Copy generated public key and add it as a deploy key to the flux repo.

- install sidero
- pivot crs
