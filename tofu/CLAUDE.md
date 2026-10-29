# Rules and Reference

## Working style

- This is a learning setup: User implement and vet every change myself. Give plans first, then the
  exact snippet or file to paste. Don't edit, commit or push anything in the repo
- Give snippets, not full files: just the changed block, with where it goes (file + the
  section or neighbouring lines). One file per answer unless I ask for more.
- If a change is big enough to need several full files, or touches several files, it needs a plan
  first. Use plan mode or give a short plan (files, what changes, why), and wait for my OK before
  writing any of it. Then go one step at a time.
- Only send a whole file when I ask for it and it is too large for the chat.
- Keep it simple. Don't add features or extra hardening that wasn't ask for; suggest them instead.
- Do not assume the user has pushed to main. They might be working from local and testing before pushing.
  Use `git fetch origin main` and read from `origin/main` (`git show origin/main:<path>`, `git diff`);
  don't pull or merge `main` into the session branch.
- Prefer Docker secrets over `.env` values for anything sensitive.

## Git / Branch Rules

- **Never modify `main` directly.** No commits, no pushes, no merges into `main`, under any circumstances.
- **Only work on a branch when explicitly told to.** Don't create or switch branches on your own initiative.
- **Minimal footprint.** Only touch the files necessary for the task at hand. Do not refactor, reformat, "clean up," or edit unrelated files even if you notice something you'd change.
- **Keep the session branch clean.** In cloud sessions, never merge or pull `main` into the working
  branch just to read it: that leaves commits on the branch that aren't yours and the stop hook asks
   to push them. Fetch and read `origin/main` instead. If it happens anyway, say so once and
  ignore the stop hook for the rest of the session; never push those commits.

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

## Repo layout

- `ansible/`: provisioning and config of all hosts (run playbooks from this folder).
- `tofu/`: OpenTofu for Proxmox VMs (`bpg/proxmox` provider, one provider alias per node,
  reusable `modules/debian_vm`). Secrets are in gitignored `*.tfvars`.
- `argocd/` + `k8s-apps/`: k3s cluster apps (see the ArgoCD / Helm section above).
- `Reference.md`: command cheat sheet (tofu, argocd, kubectl, helm, kubeseal, resticprofile).

## Ansible vars and vault

- Variables live in `group_vars/<group>/` and `host_vars/<host>/`, each with:
  - `vars.yml`: plain values, plus secret names mapped to the vault, e.g.
    `restic_apps_password: "{{ vault_restic_apps_password }}"`;
  - `vault.yml`: ansible-vault encrypted, holds only `vault_*` values.
  - Some hosts split extra vars into more files (`samba.yml`, `snapraid.yml`, `iptables.yml`, ...).
- Templates and roles always use the plain name, never `vault_*` directly.
- New secret = add `vault_x` to vault.yml and `x: "{{ vault_x }}"` to vars.yml.
- The vault password file is `ansible/.vault-password` (gitignored, set in `ansible.cfg`).
- Any file with "vault" in its path must be encrypted. The pre-commit hook in `.git-hooks/` checks
  this; install it with `git-init.sh`. This includes whole files such as `files/<host>/vault/wg0.conf`.
- Shared defaults in `group_vars/all/vars.yml`:
  - `primary_user` uid/gid 1000;
  - `docker_user`/`docker_group` = primary user, `compose_puid`/`compose_guid` = 1000.

## Docker Compose deployment (`roles/docker-compose`)

- Per-host source tree `ansible/files/<inventory_hostname>/`:
  - `docker/`: `docker-compose.yml.j2` (networks + `include:` of the stack files), `.env.j2`,
    and `compose/<stack>.yml.j2` (core, arr, downloaders, media, utilities, game-servers).
  - `appdata/<app>/...`: config files for containers.
  - `secrets/<name>.j2`: one file per Docker secret.
  - `vault/`: encrypted files copied by specific roles (e.g. wireguard `wg0.conf`).
- Where things end up on the host (`docker_dir` = `/opt/docker`):
  - `docker/` + the role's own `templates/compose/` (`_anchors.yml.j2`, `common.yml.j2`, hwaccel)
    → rendered into `/opt/docker/`, `.j2` stripped.
  - `appdata/` → `/opt/docker/appdata/` (`$CONTAINER_APPDATA_DIR`). Directories are created,
    `*.j2` files are templated and everything else is copied as is. The whole tree is walked, so a
    new file is picked up automatically, with no task changes. Add `.gitkeep` to create an empty folder.
  - `secrets/` → `/opt/docker/secrets/`, `.j2` stripped.
- The role then runs `docker compose up` (`community.docker.docker_compose_v2`) on `/opt/docker`.
- Tags:
  - `docker-compose`: the whole role;
  - `compose-setup`: secrets + appdata only, so `--tag docker-compose --skip-tag compose-setup`
    re-renders compose files and restarts without touching appdata.
  - Typical run: `ansible-playbook setup-nas.yml --tag docker-compose`.
- Other Docker roles run before it: `docker-services/traefik` (acme.json, logrotate, base middleware
  rules), `wireguard-client`, `filebrowser`.

## Compose conventions

- Each stack file starts with `{% include '_anchors.yml.j2' %}`. That gives the env anchors
  `*primary-tz-puid-pgid` (TZ + PUID/PGID 1000) and `*default-tz-puid-pgid` (root).
- Services extend a base from `common.yml`:
  - `common-keys-core` / `common-keys-apps`: `proxies` network, restart policy, no-new-privileges;
  - `common-keys-*-vpn`: run inside the `wireguard` container's network (used by the downloaders).
- Services set `container_name`, and other services rely on those names (traefik, socket-proxy, resticprofile).
- Paths come from `.env`: `$CONTAINER_APPDATA_DIR`, `$DATA_DIR`, `$DOCKER_DIR`, `$DOMAIN_NAME`, ...
- Secrets:
  - declared in a top-level `secrets:` block of the stack file, as `file: ../secrets/<name>.txt`;
  - mounted per service at `/run/secrets/<name>`;
  - templated from `files/<host>/secrets/<name>.txt.j2`, which usually holds just `{{ var }}`.
- Networks:
  - `proxies` (10.17.100.0/24) for anything Traefik routes to;
  - `socket_proxy` for access to the Docker API through `socket-proxy`
    (tecnativa, `tcp://socket-proxy:2375`). Nothing mounts the Docker socket directly.

## Traefik

- Container routes are labels on the service, with the router named `<app>-rtr` and the service
  `<app>-svc`, entrypoint `websecure`, host `<sub>.$DOMAIN_NAME`.
- Middleware chains are defined in the traefik role (`chain-oauth@file`, `chain-no-auth`, ...).
- Routes to non-Docker hosts are file rules in `files/<host>/appdata/traefik/rules/app-*.yml.j2`.
- Certificates: Let's Encrypt DNS-01 through Route 53 (`dns-route53`, the default resolver on `websecure`).
- New subdomain = add it to `sub_domains` in host vars. The ddns-route53 container in `core.yml`
  loops over that list to create the A records.
- Auth: oauth2-proxy (Google, whitelist emails in a secret). Stormfront uses Authelia.

## Backups (mediaserver)

- `resticprofile` container (stack `utilities.yml`), config in `appdata/resticprofile/profiles.yaml.j2`.
- Repos go to Garage (S3 on the NAS) and Backblaze B2 through rclone remotes set by env in a secret.
- Results are pushed to Uptime Kuma push monitors.
- Commands are in `Reference.md`.
