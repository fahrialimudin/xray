#!/bin/bash
MYIP=$(wget -qO- ipv4.icanhazip.com);
echo "Checking VPS"
clear

RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'

# ====================================================
# DROPBEAR USER LOGIN
# Metode baru: gunakan ss/netstat + /proc untuk detect
# user tanpa bergantung pada format log auth.log lama
# ====================================================
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m         Dropbear User Login       \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "PID  |  Username  |  IP Address"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

FOUND_DB=0
while IFS= read -r DBPID; do
    # Ambil IP remote dari koneksi yang dipegang PID ini
    REMOTE_IP=$(ss -tnp 2>/dev/null | grep "pid=${DBPID}," | awk '{print $5}' | \
        sed 's/\[//g;s/\]//g' | cut -d: -f1 | grep -v '^$' | head -1)
    [ -z "$REMOTE_IP" ] && REMOTE_IP=$(netstat -tnp 2>/dev/null | \
        grep "${DBPID}/dropbear" | awk '{print $5}' | cut -d: -f1 | grep -v '^$' | head -1)

    # Ambil UID dari /proc lalu convert ke username
    UID_VAL=$(awk '/^Uid:/{print $2}' /proc/${DBPID}/status 2>/dev/null)
    DB_USER=""
    [ -n "$UID_VAL" ] && DB_USER=$(getent passwd "$UID_VAL" 2>/dev/null | cut -d: -f1)

    # Fallback: cari di auth.log
    if [ -z "$DB_USER" ]; then
        for LOG in /var/log/auth.log /var/log/secure; do
            [ -f "$LOG" ] || continue
            DB_USER=$(grep "dropbear\[${DBPID}\]" "$LOG" 2>/dev/null | \
                grep -iE "auth succeeded|Authenticated|Password auth" | \
                grep -oP "(?<=user '|for |password auth succeeded: ')[a-zA-Z0-9_]+" | tail -1)
            [ -n "$DB_USER" ] && break
        done
    fi

    if [ -n "$DB_USER" ] && [ -n "$REMOTE_IP" ]; then
        echo "$DBPID - $DB_USER - $REMOTE_IP"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        FOUND_DB=1
    fi
done < <(ps aux | grep -i dropbear | grep -v grep | awk '{print $2}')

if [ $FOUND_DB -eq 0 ]; then
    echo -e " ${RED}Tidak ada user Dropbear yang terkoneksi${NC}"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
fi

echo " "

# ====================================================
# OPENSSH USER LOGIN
# Metode baru: gunakan 'who' + 'ss' yang akurat di
# Ubuntu 22/24 tanpa bergantung pada PID match di log
# ====================================================
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m          OpenSSH User Login       \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "PID  |  Username  |  IP Address"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

FOUND_SSH=0
# 'who' memberi info sesi login aktif secara akurat
while IFS= read -r line; do
    SSH_USER=$(echo "$line" | awk '{print $1}')
    FROM=$(echo "$line" | grep -oP '\(\K[^\)]+')
    # Cari PID sshd untuk user ini
    SSH_PID=$(ps aux | grep "sshd:.*${SSH_USER}" | grep -v grep | head -1 | awk '{print $2}')
    [ -z "$SSH_PID" ] && SSH_PID="?"
    if [ -n "$SSH_USER" ] && [ -n "$FROM" ]; then
        echo "$SSH_PID - $SSH_USER - $FROM"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        FOUND_SSH=1
    fi
done < <(who | grep pts | grep -v "(:0)")

if [ $FOUND_SSH -eq 0 ]; then
    echo -e " ${RED}Tidak ada user SSH yang terkoneksi${NC}"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
fi

echo " "

# ====================================================
# OPENVPN TCP USER LOGIN
# ====================================================
if [ -f "/etc/openvpn/server/openvpn-tcp.log" ]; then
    echo " "
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m          OpenVPN TCP User Login         \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo "Username  |  IP Address  |  Connected Since"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    grep -w "^CLIENT_LIST" /etc/openvpn/server/openvpn-tcp.log | \
        cut -d ',' -f 2,3,8 | sed -e 's/,/      /g'
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
fi

# ====================================================
# OPENVPN UDP USER LOGIN
# ====================================================
if [ -f "/etc/openvpn/server/openvpn-udp.log" ]; then
    echo " "
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m          OpenVPN UDP User Login         \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo "Username  |  IP Address  |  Connected Since"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    grep -w "^CLIENT_LIST" /etc/openvpn/server/openvpn-udp.log | \
        cut -d ',' -f 2,3,8 | sed -e 's/,/      /g'
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
fi

echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
