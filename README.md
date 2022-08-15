# server-config
The server configurations that I use. Serves a variety of docker service through traefik and authenticates users using Authelia.

I am now trying to follow the infrastructure as code methodology.<br />
Mediaserver is completely managed by ansible.<br />
Stormfront is in the process of being converted to an ansible configuration.<br />
pfsense and esxi are something to look into at a later date.


Command to initialize a server:<br />
`ansible-playbook setup-common.yml -l stormfront -e "ansible_user=debian" -k`

Docker configuration based on guide found here:<br />
https://www.smarthomebeginner.com/traefik-2-docker-tutorial/ <br />
https://github.com/htpcBeginner/docker-traefik

## Docker Folder Structure
The docker folder is located in the users home directory.

This is the structure for the docker folder:
```
|-- docker/
|   |-- containers/
|   |   |-- nginx/
|   |   |-- muximux/
|   |   |-- .../
|   |-- docker-compose.yml
```

The `docker-compose.yml` file contains the setup information for all the docker containers.

The `containers/` folder hold the config files for the containers. The `.gitkeep` files are only there so the empty directories get added to github.

## TODO
### Stormfront
- Setup Stormfront vpn: Either openvpn or watchtower
- Setup basic Stormfront server functionality with ansible.
- Give Stormfront containers for another user.
### Mediaserver
- Guacamole remote desktop solution
- Music organization through Lidarr
- Setup FoundryVTT and supporting tools for video chat.
- Add ACL configuration to server folders.
- Better user setup for samba share.
- NFS share for data folder.
- Look into configuring home pfsense router with ansible.
- Look into configuring ESXI with Ansible.
- Setup smarthome server with ansible

## Done
- Complete setup from a fresh debian install
- Setup firewall with iptables
- Manage docker-compose file with templates
- Mergerfs fstab configuration of all drives
- Stable samba configuration.
- Quickly setup new drive folder structure
- Snapraid setup and configuration
- Nightly backup of docker folder with 7 day cleanup
- Convert Nginx config to role or reconfigure with traefik v2.
- Get letsencrypt working again with my domain name.
- Add Authelia to external network for remote access.
- Playbook to restore docker container files in case of rebuild.