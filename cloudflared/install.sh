
#-------------   Install cloudflared in Rocky linux 10-----------------------------------------
# Add repo
curl -fsSl https://pkg.cloudflare.com/cloudflared-ascii.repo | tee /etc/yum.repos.d/cloudflared.repo
dnf update -y
dnf install cloudflared -y

# A solution for now (if anyone finds this) is to disable and then re-enable GPG checking in the repo before and after the install for now as a bypass.

# Disable gpgcheck
# sed -i 's/gpgcheck=1/gpgcheck=0/g'  /etc/yum.repos.d/cloudflared.repo

# Enable gpgcheck again
# sed -i 's/gpgcheck=0/gpgcheck=1/g'  /etc/yum.repos.d/cloudflared.repo

cloudflared --version

# 1. Login in cloudflare in browser

# 2. Login in console 
cloudflared tunnel login

#copy url and paste the same browser and select domain


# 3. create tunel 
cloudflared tunnel create testconfig


# 4 create config file
touch  /etc/cloudflared/config.yml

# ---- content config file -----------------------------
# tunnel: 1fe666e2-0e97-43a1-b1e4-96420451cd84
# credentials-file: /root/.cloudflared/1fe666e2-0e97-43a1-b1e4-96420451cd84.json

# # If you are connecting a private network:
# warp-routing:
  # enabled: true

# ingress:
  # # Rules map traffic from a hostname to a local service:
  # - hostname: site-01.example.com
    # service: https://localhost:44301
    # originRequest:
     # noTLSVerify: true
  # - hostname: site-02.example.com
    # service: https://localhost:44302
    # originRequest:
     # noTLSVerify: true
  # - hostname: site-03.example.com
    # service: https://localhost:44303
    # originRequest:
     # noTLSVerify: true
  # # Rules can match the request's hostname to a wildcard character:
  # # - hostname: "*.example.com"
    # # service: https://localhost:8002
    # # originRequest:
    # #  noTLSVerify: true
  # #
  # - hostname: cns-01.example.com
    # service: ssh://localhost:22
  # - service: http_status:404
  
# ---------------------------------------------------------------  


# 5. install cloudflared as service
cloudflared service install

systemctl enable cloudflared
systemctl disable cloudflared
systemctl start cloudflared
systemctl restart cloudflared
systemctl stop cloudflared
systemctl status cloudflared

journalctl -xeu cloudflared


# 6. view tunel info 
cloudflared tunnel info testconfig

# 7. create dns record 
cloudflared tunnel route dns testconfig site-01.example.com
cloudflared tunnel route dns testconfig site-02.example.com
cloudflared tunnel route dns testconfig site-03.example.com

cloudflared tunnel route dns testconfig cns-01.example.com


# 8. viwe tunels 
cloudflared tunnel list


# 9. Delete a tunnel
cloudflared tunnel cleanup testconfig
cloudflared tunnel delete testconfig



# https://bytexd.com/cloudflare-tunnel-tutorial-expose-web-services-to-the-internet/

# https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/do-more-with-tunnels/local-management/configuration-file/
# https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/do-more-with-tunnels/local-management/tunnel-useful-commands/
# https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/routing-to-tunnel/protocols/
# https://community-charts.github.io/docs/charts/cloudflared/ingress-configuration
