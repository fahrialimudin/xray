#!/bin/bash
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
echo "Checking VPS"; clear
mapfile -t USERS < <(grep '^#&#' /etc/xray/config.json | awk '{print $2}' | sort -u)
echo "-----------------------------------------"
echo "---------=[ Trojan User Login - LIVE ]=---------"
echo "-----------------------------------------"
echo -e " ${YELLOW}Koneksi aktif 60 detik terakhir${NC}"
echo "-----------------------------------------"
if [ ${#USERS[@]} -eq 0 ]; then
    echo -e " ${RED}Tidak ada akun Trojan di config${NC}"; echo "-----------------------------------------"
    read -n 1 -s -r -p "Press any key to back on menu"; menu; exit
fi
NOW=$(date +%s); WINDOW=60; FOUND_ANY=0
for akun in "${USERS[@]}"; do
    [ -z "$akun" ] && continue
    IPS=$(grep "email: ${akun}$" /var/log/xray/access.log 2>/dev/null | \
    awk -v now="$NOW" -v window="$WINDOW" '{
        dt=$1" "$2; sub(/\.[0-9]+/,"",dt); gsub("/","-",dt)
        cmd="date -d \""dt"\" +%s 2>/dev/null"; cmd|getline epoch; close(cmd)
        if(epoch+0>0 && (now-epoch+0)<=window){
            for(i=1;i<=NF;i++){if($i=="from"){ip=$(i+1);sub(/:[0-9]+$/,"",ip);if(ip!=""&&ip!~/^127\./)print ip}}
        }
    }' | sort | uniq)
    if [ -n "$IPS" ]; then
        COUNT=$(echo "$IPS" | wc -l)
        echo -e "user : ${GREEN}$akun${NC}  ($COUNT IP)"
        echo "$IPS" | nl -ba; echo "-----------------------------------------"; FOUND_ANY=1
    fi
done
[ $FOUND_ANY -eq 0 ] && echo -e " ${RED}Tidak ada user Trojan yang terkoneksi${NC}" && echo "-----------------------------------------"
echo ""; read -n 1 -s -r -p "Press any key to back on menu"; menu
