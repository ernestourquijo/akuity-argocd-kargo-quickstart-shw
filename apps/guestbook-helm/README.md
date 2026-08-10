# guestbook-helm — Helm chart, promotions commit to main

The second app in this quickstart, deliberately contrasting with the original
`guestbook` app (Kustomize, promotions push rendered `env/<stage>` branches).

Argo CD renders the chart in `chart/` **from main**, layering the
per-environment values file `env/<stage>/values.yaml` on top of the chart
defaults (multi-source `$values` pattern — see `argocd/appset.yaml`). On every
promotion Kargo:

1. clones main,
2. runs `yaml-update` to bump `image.tag` in `env/<stage>/values.yaml`,
3. commits and pushes to main,
4. syncs the Argo CD Application `guestbook-helm-<stage>`.

**Pipeline:** `Warehouse → dev → staging → prod`
**Namespaces:** `guestbook-helm-{dev,staging,prod}` on cluster `epam-kargo`
**Kargo Project / Argo CD AppProject:** both named `guestbook-helm`

## Things to know

- **Do not re-run `../../personalize.sh`.** It rewrites `ghcr.io/<anything>` →
  `ghcr.io/<your-username>`, which would break this chart's reference to the
  public `ghcr.io/akuity/guestbook` image (`chart/values.yaml`,
  `kargo/warehouse.yaml`, `kargo/tasks.yaml`). It has already been run for the
  original app; running it again is destructive here.
- **Kargo credentials are per-project.** The `github-creds` Secret that
  `add-credential.sh` installed lives in the `akuity-argocd-kargo-quickstart`
  namespace and does **not** apply here. Promotions fail on `git-push` with an
  auth error until a git credential exists in namespace `guestbook-helm` — see
  the repo root README.
- **The Warehouse is image-only** — promotions commit to main, so a git
  subscription to main would loop. Conversely, `kargo/warehouse.yaml` (the
  original app) now carries `excludePaths: [apps]` so this app's commits to
  main don't produce spurious Freight over there.
- **No rendered branches.** Nothing in this app pushes to `env/*` branches.
- The per-env values files live *outside* the chart directory, which is why
  the Application uses two sources (`$values` ref). Argo CD cannot reference
  value files outside a single source's path.
- Chart resource names are hardcoded to `guestbook`; that is fine because each
  stage gets its own namespace.

## Local check

```sh
helm template guestbook-helm-dev chart -f env/dev/values.yaml
```
