# Rules and Reference

## Git / Branch Rules

- **Never modify `main` directly.** No commits, no pushes, no merges into `main`, under any circumstances.
- **Only work on a branch when explicitly told to.** Don't create or switch branches on your own initiative.
- **Minimal footprint.** Only touch the files necessary for the task at hand. Do not refactor, reformat, "clean up," or edit unrelated files even if you notice something you'd change.
- **Never merge anything.** Not a branch into `main`, not a PR — merging is done by a human only.
- **Pull requests require explicit go-ahead.** You may open a PR if it seems useful, but only after being told it's okay to do so for that specific piece of work. Don't open one proactively.

If a task seems to require touching `main`, merging, or opening a PR without having been given permission, stop and ask instead of proceeding.

## ArgoCD / Helm pattern used in this repo

Structure: "app of apps" (official ArgoCD term) with one "wrapper chart" per app (informal term).

- `argocd/bootstrap/` — one-time manual bootstrap: installs ArgoCD and the root Application.
- `argocd/apps/*.yaml` — one ArgoCD Application per app, each pointing at `k8s-apps/<name>`.
  The root Application watches this folder. Ordering between apps uses
  `argocd.argoproj.io/sync-wave` (e.g. cert-manager `-1`, traefik `1`).
- `k8s-apps/<name>/` — a wrapper chart:
  - `Chart.yaml` lists an upstream chart under `dependencies:`
    (`repository:` may be `https://...` or `oci://...`).
  - `values.yaml` — settings for the upstream chart go under a top-level key matching the dependency's name (e.g. `cert-manager:`). Top-level keys outside that belong to the wrapper chart itself; only `global:` is shared with both.
  - `templates/` — extra manifests for that app (CRs, SealedSecrets, etc.).
