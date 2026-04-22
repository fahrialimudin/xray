#!/bin/bash
MYIP=$(wget -qO- ipv4.icanhazip.com);
echo "Checking VPS"
clear
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;100;33m         • RESTART MENU •          \E[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -e " [\e[36m•1\e[0m] Restart All Services"
echo -e " [\e[36m•2\e[0m] Restart OpenSSH"
echo -e " [\e[36m•3\e[0m] Restart Dropbear"
echo -e " [\e[36m•4\e[0m] Restart Stunnel4"
echo -e " [\e[36m•5\e[0m] Restart Nginx"
echo -e " [\e[36m•6\e[0m] Restart Badvpn"
echo -e " [\e[36m•7\e[0m] Restart XRAY"
echo -e " [\e[36m•8\e[0m] Restart Websocket"
echo -e ""
echo -e " [\e[31m•0\e[0m] \e[31mBACK TO MENU\033[0m"
echo -e ""
echo -e "Press x or [ Ctrl+C ] • To-Exit"
echo -e ""
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
read -p " Select menu : " Restart
echo -e ""
sleep 1
clear
case $Restart in
        1)
        clear
        echo -e "[ \033[32mInfo\033[0m ] Restart All Services"
        systemctl restart ssh
        systemctl restart dropbear
        systemctl restart stunnel4
        systemctl restart fail2ban
        systemctl restart cron
        systemctl restart nginx
        systemctl restart vnstat
        systemctl restart xray
        pkill badvpn-udpgw 2>/dev/null; sleep 1
        screen -dmS badvpn1 badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 50
        screen -dmS badvpn2 badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 50
        screen -dmS badvpn3 badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 50
        screen -dmS badvpn4 badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 50
        systemctl restart ws-dropbear.service
        systemctl restart ws-stunnel.service
        echo -e "[ \033[32mok\033[0m ] All Services Restarted"
        echo ""
        echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -n 1 -s -r -p "Press any key to back on menu"
        restart
        ;;
        2)
        clear
        echo -e "[ \033[32mInfo\033[0m ] Restart OpenSSH"
        systemctl restart ssh
        echo -e "[ \033[32mok\033[0m ] SSH Restarted"
        echo ""
        echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -n 1 -s -r -p "Press any key to back on menu"
        restart
        ;;
        3)
        clear
        echo -e "[ \033[32mInfo\033[0m ] Restart Dropbear"
        systemctl restart dropbear
        echo -e "[ \033[32mok\033[0m ] Dropbear Restarted"
        echo ""
        echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -n 1 -s -r -p "Press any key to back on menu"
        restart
        ;;
        4)
        clear
        echo -e "[ \033[32mInfo\033[0m ] Restart Stunnel4"
        systemctl restart stunnel4
        echo -e "[ \033[32mok\033[0m ] Stunnel4 Restarted"
        echo ""
        echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -n 1 -s -r -p "Press any key to back on menu"
        restart
        ;;
        5)
        clear
        echo -e "[ \033[32mInfo\033[0m ] Restart Nginx"
        systemctl restart nginx
        echo -e "[ \033[32mok\033[0m ] Nginx Restarted"
        echo ""
        echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -n 1 -s -r -p "Press any key to back on menu"
        restart
        ;;
        6)
        clear
        echo -e "[ \033[32mInfo\033[0m ] Restart Badvpn (max-clients 50 each)"
        pkill badvpn-udpgw 2>/dev/null; sleep 1
        screen -dmS badvpn1 badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 50
        screen -dmS badvpn2 badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 50
        screen -dmS badvpn3 badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 50
        screen -dmS badvpn4 badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 50
        echo -e "[ \033[32mok\033[0m ] Badvpn Restarted (7100-7400, max 200 total)"
        echo ""
        echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -n 1 -s -r -p "Press any key to back on menu"
        restart
        ;;
        7)
        clear
        echo -e "[ \033[32mInfo\033[0m ] Restart XRAY"
        systemctl restart xray
        echo -e "[ \033[32mok\033[0m ] XRAY Restarted"
        echo ""
        echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -n 1 -s -r -p "Press any key to back on menu"
        restart
        ;;
        8)
        clear
        echo -e "[ \033[32mInfo\033[0m ] Restart Websocket"
        systemctl restart ws-dropbear.service
        systemctl restart ws-stunnel.service
        echo -e "[ \033[32mok\033[0m ] Websocket Restarted"
        echo ""
        echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -n 1 -s -r -p "Press any key to back on menu"
        restart
        ;;
        0)
        menu
        exit
        ;;
        x)
        clear
        exit
        ;;
        *) echo -e "" ; echo "Anda salah tekan" ; sleep 1 ; restart ;;
esac
