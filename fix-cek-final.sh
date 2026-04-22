#!/bin/bash
# ================================================
# fix-cek.sh - FINAL - Real-time Check User Login
# Deteksi berdasarkan activity log 60 detik terakhir
# ================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}   Fix Check User Login - FINAL Real-time v3    ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd /usr/bin || { echo -e "${RED}Gagal masuk /usr/bin${NC}"; exit 1; }

# ============================================================
# FUNGSI UTAMA: buat script cek xray real-time
# Logika: ambil baris dari access.log yang timestampnya
# dalam 60 detik terakhir, lalu extract email + IP
# ============================================================
make_xray_cek() {
    local OUTFILE="$1"
    local MARKER="$2"
    local LABEL="$3"
    local DIV="$4"

    cat > "$OUTFILE" << HEREDOC
#!/bin/bash
echo "Checking VPS"; clear
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'

# Ambil username dari config.json berdasarkan marker
mapfile -t USERS < <(grep '${MARKER}' /etc/xray/config.json | awk '{print \$2}' | sort -u)

echo "${DIV}"
echo "---------=[ ${LABEL} User Login - LIVE ]=---------"
echo "${DIV}"
echo -e " \${YELLOW}Menampilkan koneksi aktif (60 detik terakhir)\${NC}"
echo "${DIV}"

if [ \${#USERS[@]} -eq 0 ]; then
    echo -e " \${RED}Tidak ada akun ${LABEL} di config\${NC}"
    echo "${DIV}"
    read -n 1 -s -r -p "Press any key to back on menu"; menu; exit
fi

# Waktu sekarang dalam epoch seconds
NOW=\$(date +%s)
WINDOW=60  # detik - koneksi dianggap aktif jika ada log dalam 60 detik terakhir

FOUND_ANY=0
for akun in "\${USERS[@]}"; do
    [ -z "\$akun" ] && continue

    # Baca access.log, filter baris dengan email=akun DAN timestamp dalam WINDOW detik terakhir
    # Format log: 2026/04/22 13:25:18.554542 from IP:PORT accepted ... email: USERNAME
    IPS=\$(grep "email: \${akun}\$" /var/log/xray/access.log 2>/dev/null | \
    awk -v now="\$NOW" -v window="\$WINDOW" '{
        # Parse timestamp dari field 1 dan 2
        # field 1: 2026/04/22, field 2: 13:25:18.554542
        dt = \$1 " " \$2
        # Hapus sub-detik (.554542)
        sub(/\.[0-9]+/, "", dt)
        # Ganti / dengan - untuk format date
        gsub("/", "-", dt)
        # Konversi ke epoch
        cmd = "date -d \"" dt "\" +%s 2>/dev/null"
        cmd | getline epoch
        close(cmd)
        epoch = epoch + 0
        if (epoch > 0 && (now - epoch) <= window) {
            # Ambil IP dari field "from IP:PORT"
            for (i=1; i<=NF; i++) {
                if (\$i == "from") {
                    ip = \$(i+1)
                    # Hapus :PORT di belakang
                    sub(/:[0-9]+$/, "", ip)
                    # Skip loopback
                    if (ip != "" && ip !~ /^127\./) print ip
                }
            }
        }
    }' | sort | uniq)

    if [ -n "\$IPS" ]; then
        COUNT=\$(echo "\$IPS" | wc -l)
        echo -e "user : \${GREEN}\$akun\${NC}  (\$COUNT IP aktif)"
        echo "\$IPS" | nl -ba
        echo "${DIV}"
        FOUND_ANY=1
    fi
done

if [ \$FOUND_ANY -eq 0 ]; then
    echo -e " \${RED}Tidak ada user ${LABEL} yang sedang terkoneksi\${NC}"
    echo "${DIV}"
fi

echo ""
read -n 1 -s -r -p "Press any key to back on menu"; menu
HEREDOC
    chmod +x "$OUTFILE"
}

# ------------------------------------------------
echo -e " ${GREEN}[1/5]${NC} Mengupdate cek (SSH & Dropbear)..."
cat > /usr/bin/cek << 'SCRIPT_CEK'
#!/bin/bash
echo "Checking VPS"
clear
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m         Dropbear User Login       \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "PID  |  Username  |  IP Address"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
FOUND_DB=0
while IFS= read -r DBPID; do
    REMOTE_IP=$(ss -tnp 2>/dev/null | grep "pid=${DBPID}," | awk '{print $5}' | \
        sed 's/\[//g;s/\]//g' | rev | cut -d: -f2- | rev | grep -v '^127\.' | grep -v '^$' | head -1)
    [ -z "$REMOTE_IP" ] && REMOTE_IP=$(netstat -tnp 2>/dev/null | grep "${DBPID}/dropbear" | \
        awk '{print $5}' | rev | cut -d: -f2- | rev | grep -v '^127\.' | grep -v '^$' | head -1)
    UID_VAL=$(awk '/^Uid:/{print $2}' /proc/${DBPID}/status 2>/dev/null)
    DB_USER=""
    [ -n "$UID_VAL" ] && [ "$UID_VAL" != "0" ] && DB_USER=$(getent passwd "$UID_VAL" 2>/dev/null | cut -d: -f1)
    if [ -z "$DB_USER" ]; then
        for LOG in /var/log/auth.log /var/log/secure; do
            [ -f "$LOG" ] || continue
            DB_USER=$(grep "dropbear\[${DBPID}\]" "$LOG" 2>/dev/null | \
                grep -iE "auth succeeded|Password auth" | \
                grep -oP "[a-zA-Z0-9_]+" | grep -v dropbear | tail -1)
            [ -n "$DB_USER" ] && break
        done
    fi
    if [ -n "$DB_USER" ] && [ -n "$REMOTE_IP" ]; then
        echo "$DBPID - $DB_USER - $REMOTE_IP"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        FOUND_DB=1
    fi
done < <(ps aux | grep -i dropbear | grep -v grep | awk '{print $2}')
[ $FOUND_DB -eq 0 ] && echo -e " ${RED}Tidak ada user Dropbear yang terkoneksi${NC}" && \
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " "

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m          OpenSSH User Login       \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "PID  |  Username  |  IP Address"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
FOUND_SSH=0
while IFS= read -r line; do
    SSH_USER=$(echo "$line" | awk '{print $1}')
    FROM=$(echo "$line" | grep -oP '\(\K[^\)]+')
    SSH_PID=$(ps aux | grep "sshd:.*${SSH_USER}" | grep -v grep | head -1 | awk '{print $2}')
    [ -z "$SSH_PID" ] && SSH_PID="?"
    if [ -n "$SSH_USER" ] && [ -n "$FROM" ]; then
        echo "$SSH_PID - $SSH_USER - $FROM"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        FOUND_SSH=1
    fi
done < <(who | grep pts | grep -v "(:0)")
[ $FOUND_SSH -eq 0 ] && echo -e " ${RED}Tidak ada user SSH yang terkoneksi${NC}" && \
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

if [ -f "/etc/openvpn/server/openvpn-tcp.log" ]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m          OpenVPN TCP User Login         \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    grep -w "^CLIENT_LIST" /etc/openvpn/server/openvpn-tcp.log | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g'
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
fi
if [ -f "/etc/openvpn/server/openvpn-udp.log" ]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m          OpenVPN UDP User Login         \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    grep -w "^CLIENT_LIST" /etc/openvpn/server/openvpn-udp.log | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g'
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
fi
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
SCRIPT_CEK
chmod +x /usr/bin/cek
echo -e "    ${GREEN}OK${NC}"

# ------------------------------------------------
echo -e " ${GREEN}[2/5]${NC} Mengupdate cek-ws (Vmess)..."
make_xray_cek "/usr/bin/cek-ws" "^### " "Vmess" "----------------------------------------"
echo -e "    ${GREEN}OK${NC}"

echo -e " ${GREEN}[3/5]${NC} Mengupdate cek-vless (Vless)..."
make_xray_cek "/usr/bin/cek-vless" "^#& " "Vless" "----------------------------------------"
echo -e "    ${GREEN}OK${NC}"

echo -e " ${GREEN}[4/5]${NC} Mengupdate cek-tr (Trojan)..."
make_xray_cek "/usr/bin/cek-tr" "^#&#" "Trojan" "-----------------------------------------"
echo -e "    ${GREEN}OK${NC}"

echo -e " ${GREEN}[5/5]${NC} Membuat cek-ssws (Shadowsocks)..."
make_xray_cek "/usr/bin/cek-ssws" "^### " "Shadowsocks" "--------------------------------------------"
echo -e "    ${GREEN}OK${NC}"

# ------------------------------------------------
echo -e " ${YELLOW}[+]${NC} Update menu m-ssws..."
if [ -f /usr/bin/m-ssws ] && ! grep -q "cek-ssws" /usr/bin/m-ssws; then
    sed -i 's/5) clear ; cat \/etc\/log-create-shadowsocks.log/5) clear ; cek-ssws ;;\n6) clear ; cat \/etc\/log-create-shadowsocks.log/' /usr/bin/m-ssws
    echo -e "    ${GREEN}OK${NC}"
else
    echo -e "    ${GREEN}Skip${NC}"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Patch FINAL selesai! Real-time 60 detik.${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e " ${GREEN}✔${NC} /usr/bin/cek       → SSH & Dropbear"
echo -e " ${GREEN}✔${NC} /usr/bin/cek-ws    → Vmess  (real-time)"
echo -e " ${GREEN}✔${NC} /usr/bin/cek-vless → Vless  (real-time)"
echo -e " ${GREEN}✔${NC} /usr/bin/cek-tr    → Trojan (real-time)"
echo -e " ${GREEN}✔${NC} /usr/bin/cek-ssws  → Shadowsocks (real-time)"
echo ""
