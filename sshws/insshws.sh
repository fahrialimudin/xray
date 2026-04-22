#!/bin/bash
# Install SSH Websocket - Fixed for Ubuntu 24.04
clear
cd

# Pastikan python3 tersedia
apt-get install -y python3 2>/dev/null

# Install ws-dropbear dan ws-stunnel dari repo (binary python)
wget -O /usr/local/bin/ws-dropbear https://raw.githubusercontent.com/fahrialimudin/xray/main/sshws/ws-dropbear
wget -O /usr/local/bin/ws-stunnel https://raw.githubusercontent.com/fahrialimudin/xray/main/sshws/ws-stunnel

chmod +x /usr/local/bin/ws-dropbear
chmod +x /usr/local/bin/ws-stunnel

# Pastikan shebang python3 benar di Ubuntu 24.04
head -1 /usr/local/bin/ws-stunnel | grep -q python || sed -i '1s|^|#!/usr/bin/python3\n|' /usr/local/bin/ws-stunnel
head -1 /usr/local/bin/ws-dropbear | grep -q python || sed -i '1s|^|#!/usr/bin/python3\n|' /usr/local/bin/ws-dropbear

# Buat systemd service ws-dropbear (port 80 - SSH WS HTTP)
cat > /etc/systemd/system/ws-dropbear.service <<-END
[Unit]
Description=Websocket-Dropbear (HTTP port 2095 internal)
Documentation=https://google.com
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python3 /usr/local/bin/ws-dropbear 2095
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
END

# Buat systemd service ws-stunnel (port 443 - SSH WSS HTTPS)
cat > /etc/systemd/system/ws-stunnel.service <<-END
[Unit]
Description=SSH Over Websocket-SSL (HTTPS port 443)
Documentation=https://google.com
After=network.target nss-lookup.target stunnel4.service

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python3 /usr/local/bin/ws-stunnel 700
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
END

# Reload dan enable semua service
systemctl daemon-reload

systemctl enable ws-dropbear.service
systemctl stop ws-dropbear.service 2>/dev/null; sleep 1
systemctl start ws-dropbear.service

systemctl enable ws-stunnel.service
systemctl stop ws-stunnel.service 2>/dev/null; sleep 1
systemctl start ws-stunnel.service

echo "[ ok ] ws-dropbear (port 2095 internal) started"
echo "[ ok ] ws-stunnel (port 700 internal -> 443 via nginx) started"
