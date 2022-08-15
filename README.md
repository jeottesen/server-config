# mediaserver-config
The mediaserver configuration that I use on my home server. Runs plex, beets, and more then serves these applications through an nginx reverse proxy server.

I am now trying to follow the infrastructure as code methodology for my server management.
Mediaserver is now completely managed by ansible.

Docker configuration based on guide found here:
https://www.smarthomebeginner.com/traefik-2-docker-tutorial/
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