#!/bin/bash
# pewarna hidup
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BGreen='\e[1;32m'
BYellow='\e[1;33m'
BBlue='\e[1;34m'
BPurple='\e[1;35m'
NC='\033[0m'
yl='\e[32;1m'
bl='\e[36;1m'
gl='\e[32;1m'
rd='\e[31;1m'
mg='\e[0;95m'
blu='\e[34m'
op='\e[35m'
or='\033[1;33m'
bd='\e[1m'
color1='\e[031;1m'
color2='\e[34;1m'
color3='\e[0m'

red='\e[1;31m'
green='\e[1;32m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
clear

# GETTING OS INFORMATION
source /etc/os-release
Versi_OS=$VERSION
ver=$VERSION_ID
Tipe=$NAME
URL_SUPPORT=$HOME_URL
basedong=$ID

# VPS IP (lokal, tanpa curl ke ipinfo.io yang lambat)
MYIP=$(cat /etc/myipvps 2>/dev/null || curl -s ifconfig.me)

# CHEK STATUS
tls_v2ray_status=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
nontls_v2ray_status=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
vless_tls_v2ray_status=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
vless_nontls_v2ray_status=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
shadowsocks=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
trojan_server=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
dropbear_status=$(systemctl status dropbear | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
stunnel_service=$(systemctl status stunnel4 | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
ssh_service=$(systemctl status ssh | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
vnstat_service=$(systemctl status vnstat | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
cron_service=$(systemctl status cron | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
fail2ban_service=$(systemctl status fail2ban | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
wstls=$(systemctl status ws-stunnel.service | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
wsdrop=$(systemctl status ws-dropbear.service | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)

# COLOR VALIDATION
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
clear

# STATUS SERVICE  SSH 
if [[ $ssh_service == "running" ]]; then 
   status_ssh=" ${GREEN}Running ${NC}( No Error )"
else
   status_ssh="${RED}  Not Running ${NC}  ( Error )"
fi

# STATUS SERVICE  VNSTAT 
if [[ $vnstat_service == "running" ]]; then 
   status_vnstat=" ${GREEN}Running ${NC}( No Error )"
else
   status_vnstat="${RED}  Not Running ${NC}  ( Error )"
fi

# STATUS SERVICE  CRONS 
if [[ $cron_service == "running" ]]; then 
   status_cron=" ${GREEN}Running ${NC}( No Error )"
else
   status_cron="${RED}  Not Running ${NC}  ( Error )"
fi

# STATUS SERVICE  FAIL2BAN 
if [[ $fail2ban_service == "running" ]]; then 
   status_fail2ban=" ${GREEN}Running ${NC}( No Error )"
else
   status_fail2ban="${RED}  Not Running ${NC}  ( Error )"
fi

# STATUS SERVICE  TLS 
if [[ $tls_v2ray_status == "running" ]]; then 
   status_tls_v2ray=" ${GREEN}Running${NC} ( No Error )"
else
   status_tls_v2ray="${RED}  Not Running${NC}   ( Error )"
fi

# STATUS SERVICE NON TLS V2RAY
if [[ $nontls_v2ray_status == "running" ]]; then 
   status_nontls_v2ray=" ${GREEN}Running ${NC}( No Error )${NC}"
else
   status_nontls_v2ray="${RED}  Not Running ${NC}  ( Error )${NC}"
fi

# STATUS SERVICE VLESS HTTPS
if [[ $vless_tls_v2ray_status == "running" ]]; then
  status_tls_vless=" ${GREEN}Running${NC} ( No Error )"
else
  status_tls_vless="${RED}  Not Running ${NC}  ( Error )${NC}"
fi

# STATUS SERVICE VLESS HTTP
if [[ $vless_nontls_v2ray_status == "running" ]]; then
  status_nontls_vless=" ${GREEN}Running${NC} ( No Error )"
else
  status_nontls_vless="${RED}  Not Running ${NC}  ( Error )${NC}"
fi
# STATUS SERVICE TROJAN
if [[ $trojan_server == "running" ]]; then 
   status_virus_trojan=" ${GREEN}Running ${NC}( No Error )${NC}"
else
   status_virus_trojan="${RED}  Not Running ${NC}  ( Error )${NC}"
fi
# STATUS SERVICE DROPBEAR
if [[ $dropbear_status == "running" ]]; then 
   status_beruangjatuh=" ${GREEN}Running${NC} ( No Error )${NC}"
else
   status_beruangjatuh="${RED}  Not Running ${NC}  ( Error )${NC}"
fi

# STATUS SERVICE STUNNEL
if [[ $stunnel_service == "running" ]]; then 
   status_stunnel=" ${GREEN}Running ${NC}( No Error )"
else
   status_stunnel="${RED}  Not Running ${NC}  ( Error )}"
fi
# STATUS SERVICE WEBSOCKET TLS
if [[ $wstls == "running" ]]; then 
   swstls=" ${GREEN}Running ${NC}( No Error )${NC}"
else
   swstls="${RED}  Not Running ${NC}  ( Error )${NC}"
fi

# STATUS SERVICE WEBSOCKET DROPBEAR
if [[ $wsdrop == "running" ]]; then 
   swsdrop=" ${GREEN}Running ${NC}( No Error )${NC}"
else
   swsdrop="${RED}  Not Running ${NC}  ( Error )${NC}"
fi

# STATUS SHADOWSOCKS
if [[ $shadowsocks == "running" ]]; then 
   status_shadowsocks=" ${GREEN}Running ${NC}( No Error )${NC}"
else
   status_shadowsocks="${RED}  Not Running ${NC}  ( Error )${NC}"
fi

# TOTAL RAM & USAGE
total_ram=`grep "MemTotal: " /proc/meminfo | awk '{ print $2}'`
free_ram=`grep "MemAvailable: " /proc/meminfo | awk '{ print $2}'`
used_ram=$(( ($total_ram - $free_ram) / 1024 ))
totalram=$(($total_ram/1024))

# CPU USAGE
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 2>/dev/null || echo "N/A")

# KERNEL TERBARU
kernelku=$(uname -r)

Name=$"fahrialimudin"
Exp=$"Lifetime"
# GETTING DOMAIN NAME
Domen="$(cat /etc/xray/domain)"
echo -e ""
echo -e "\e[1;33m -------------------------------------------------\e[0m"
echo -e "\e[1;34m                 SYSTEM INFORMATION               \e[0m"
echo -e "\e[1;33m -------------------------------------------------\e[0m"
echo -e "\e[1;32m Hostname  \e[0m: $HOSTNAME"
echo -e "\e[1;32m OS Name   \e[0m: $Tipe"
echo -e "\e[1;32m Kernel    \e[0m: $kernelku"
echo -e "\e[1;32m RAM Usage \e[0m: ${used_ram}MB / ${totalram}MB"
echo -e "\e[1;32m CPU Usage \e[0m: ${cpu_usage}%"
echo -e "\e[1;32m Public IP \e[0m: $MYIP"
echo -e "\e[1;32m Domain    \e[0m: $Domen"
echo -e "\e[1;33m -------------------------------------------------\e[0m"
echo -e "\e[1;34m              SUBSCRIPTION INFORMATION            \e[0m"
echo -e "\e[1;33m -------------------------------------------------\e[0m"
echo -e "\e[1;32m Client Name \e[0m: $Name"
echo -e "\e[1;32m Exp Script  \e[0m: $Exp"
echo -e "\e[1;32m Version     \e[0m: 1.0"
echo -e "\e[1;33m -------------------------------------------------\e[0m"
echo -e "\e[1;34m                SERVICE STATUS                    \e[0m"
echo -e "\e[1;33m -------------------------------------------------\e[0m"
echo -e "\e[1;32m SSH / TUN            \e[0m: $status_ssh"
echo -e "\e[1;32m Dropbear             \e[0m: $status_beruangjatuh"
echo -e "\e[1;32m Stunnel4             \e[0m: $status_stunnel"
echo -e "\e[1;32m Websocket (WS)       \e[0m: $swsdrop"
echo -e "\e[1;32m Websocket SSL (WSS)  \e[0m: $swstls"
echo -e "\e[1;32m XRAY (Vmess/Vless)  \e[0m: $status_tls_v2ray"
echo -e "\e[1;32m XRAY Trojan         \e[0m: $status_virus_trojan"
echo -e "\e[1;32m XRAY Shadowsocks    \e[0m: $status_shadowsocks"
echo -e "\e[1;32m Fail2Ban             \e[0m: $status_fail2ban"
echo -e "\e[1;32m Crons                \e[0m: $status_cron"
echo -e "\e[1;32m Vnstat               \e[0m: $status_vnstat"
echo -e "\e[1;33m -------------------------------------------------\e[0m"
echo -e "\e[1;34m                SERVICE & PORT INFO               \e[0m"
echo -e "\e[1;33m -------------------------------------------------\e[0m"
echo -e "\e[1;32m OpenSSH              \e[0m: 22, 9696"
echo -e "\e[1;32m SSH Websocket        \e[0m: 80"
echo -e "\e[1;32m SSH SSL Websocket    \e[0m: 443"
echo -e "\e[1;32m Stunnel4             \e[0m: 222, 777"
echo -e "\e[1;32m Dropbear             \e[0m: 109, 143"
echo -e "\e[1;32m Badvpn              \e[0m: 7100-7400 (max 200)"
echo -e "\e[1;32m Nginx               \e[0m: 81"
echo -e "\e[1;33m -------------------------------------------------\e[0m"
echo -e "\e[1;32m Vmess WS TLS        \e[0m: 443"
echo -e "\e[1;32m Vless WS TLS        \e[0m: 443"
echo -e "\e[1;32m Trojan WS TLS       \e[0m: 443"
echo -e "\e[1;32m Shadowsocks WS TLS  \e[0m: 443"
echo -e "\e[1;32m Vmess WS none TLS   \e[0m: 80"
echo -e "\e[1;32m Vless WS none TLS   \e[0m: 80"
echo -e "\e[1;32m Trojan WS none TLS  \e[0m: 80"
echo -e "\e[1;32m SS WS none TLS      \e[0m: 80"
echo -e "\e[1;32m Vmess gRPC          \e[0m: 443"
echo -e "\e[1;32m Vless gRPC          \e[0m: 443"
echo -e "\e[1;32m Trojan gRPC         \e[0m: 443"
echo -e "\e[1;32m Shadowsocks gRPC    \e[0m: 443"
echo -e "\e[1;33m -------------------------------------------------\e[0m"
echo -e "\e[1;34m                     t.me/fahrialimudin           \e[0m"
echo -e "\e[1;33m -------------------------------------------------\e[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
