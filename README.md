# mediaserver-docker-compose
The mediaserver configuration that I use on my home server. Runs plex, beets, and more then serves these applications through an nginx reverse proxy server. 

Easily add subdomain proxies and subpath proxies. Get ssl up and running through letsencrpyt and certbot.

Setup:  
1. Install docker and docker-compose.  
2. Add your email to [scripts/init-letsencrypt.sh](scripts/init-letsencrypt.sh) file and set the staging to 2  
[scripts/init-letsencrypt.sh](scripts/init-letsencrypt.sh) Line 12  
3. run ```config-replace.sh my_server your.domain.name``` where "your.domain.name" is your domain name.  
4. run docker-compose up -f  
5. run [scripts/init-letsencrypt.sh](scripts/init-letsencrypt.sh) to set up nginx with a temporary ssl certificates.  
6. When you are ready and nginx is working modify staing to 0 in [scripts/init-letsencrypt.sh](scripts/init-letsencrypt.sh) and run again to get signed certificates.  

## Docker Folder Structure
The docker folder is located in the users home directory.

This is the structure for the docker folder:
```
|-- docker/
|   |-- containers/
|   |   |-- nginx/
|   |   |-- muximux/
|   |-- docker-compose.yml
```

The `docker-compose.yml` file contains the setup information for all the docker containers.

The `scripts` folder just holds helper scripts like a cron job or the lets-encrypt setup script.

The `containers/` folder hold the config files for the containers. The `.gitkeep` files are only there so the empty directories get added to github.



  
