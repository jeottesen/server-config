# Source https://serverfault.com/questions/987686/no-network-connectivity-to-from-docker-ce-container-on-centos-8
# Masquerading allows for docker ingress and egress (this is the juicy bit)
firewall-cmd --zone=public --add-masquerade --permanent

# Specifically allow incoming traffic on port 80/443 (nothing new here)
firewall-cmd --zone=public --add-port=80/tcp
firewall-cmd --zone=public --add-port=443/tcp

# Reload firewall to apply permanent rules
firewall-cmd --reload