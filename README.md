# nginx-docker-compose
An extendable nginx reverse proxy.  
Usefull for homeassistant, plex, foundryvtt, and more.

Easily add subdomain proxies and subpath proxies. Get ssl up and running through letsencrpyt and certbot.

Setup:  
1. Install docker and docker-compose.  
2. Add your email to [scripts/init-letsencrypt.sh](scripts/init-letsencrypt.sh) file and set the staging to 2  
[scripts/init-letsencrypt.sh](scripts/init-letsencrypt.sh) Line 12  
3. run ```config-replace.sh my_server your.domain.name``` where "your.domain.name" is your domain name.  
4. run docker-compose up -f  
5. run [scripts/init-letsencrypt.sh](scripts/init-letsencrypt.sh) to set up nginx with a temporary ssl certificates.  
6. When you are ready and nginx is working modify staing to 0 in [scripts/init-letsencrypt.sh](scripts/init-letsencrypt.sh) and run again to get signed certificates.  


  


  
