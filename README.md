# server-config

The server configurations that I use. Serves a variety of services running in docker compose and reverse proxied through traefik. Servers are provisioned and configured using ansible. Currently working on transitioning some of the services to kubernetes and deploying them with argocd.

## Ansible Commands

Command to install ansible requirements:
`ansible-galaxy collection install -r requirements.yml`

Command to initialize a server:

`ansible-playbook setup-common.yml -l stormfront -e "ansible_user=debian" -k`

## First Time Server Setup

Set `ansible_become_method='su'` in `hosts.ini`.
run the playbook command with the `--ask-pass` flag.

## References

Docker compose configuration based on guide found here:

[Smart Home Beginner Guide](https://www.smarthomebeginner.com/traefik-2-docker-tutorial/)

[Smart Home Beginner Repo](https://github.com/htpcBeginner/docker-traefik)
