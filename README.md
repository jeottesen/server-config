# server-config
The server configurations that I use. Serves a variety of docker service through traefik and authenticates users using OAuth and Authelia.

Docker configuration based on guide found here:<br />
https://www.smarthomebeginner.com/traefik-2-docker-tutorial/ <br />
https://github.com/htpcBeginner/docker-traefik

## Ansible Commands
Command to install ansible requirements:<br />
`ansible-galaxy install -r requirements.yml`

Command to initialize a server:<br />
`ansible-playbook setup-common.yml -l stormfront -e "ansible_user=debian" -k`

Command to generate a hashed Authelia password:<br />
`docker run authelia/authelia:latest authelia hash-password -- 'YOUR_PA$$WORD'`

## For server first setup
Set `ansible_become_method='su'` in `hosts.ini`.
run the playbook command with the `--ask-pass` flag.

## Docker Folder Structure
The docker folder is located in the users home directory.

This is the structure for the docker folder:
```
|-- docker/
|   |-- appdata/
|   |   |-- nginx/
|   |   |-- muximux/
|   |   |-- .../
|   |-- docker-compose.yml
|   |-- .env
```

The `docker-compose.yml` file contains the setup information for all the docker containers.

The `appdata/` folder hold the config files for the containers. 