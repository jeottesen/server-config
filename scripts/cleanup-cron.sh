# Add this to the crontab to auto update and cleanup docker.
# Don't do this unless you are willing to have unexpected updates 
# break things in the future.
docker-compose -f /home/ec2-user/docker/docker-compose.yml pull
docker-compose -f /home/ec2-user/docker/docker-compose.yml up -d
docker system prune -f