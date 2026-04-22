#!/bin/bash
echo "Checking VPS"
clear
echo ""
echo ""
echo -e "[ \033[32mInfo\033[0m ] Clear RAM Cache"
sync
echo 3 > /proc/sys/vm/drop_caches
sleep 1
echo -e "[ \033[32mok\033[0m ] PageCache, Dentries & Inodes cleared"
echo ""
# Tampilkan RAM setelah clear
echo -e "[ \033[32mInfo\033[0m ] RAM Usage After Clear:"
free -h
echo ""
echo "Back to menu in 3 sec "
sleep 3
menu
