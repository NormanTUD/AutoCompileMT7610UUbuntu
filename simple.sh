#!/bin/bash

# https://askubuntu.com/questions/674116/how-to-install-tp-link-t2uh-wireless-adapter-driver-ralink-mt7610u
sudo apt-get install -y git build-essential
cd ~
git clone https://github.com/Myria-de/mt7610u_wifi_sta_v3002_dpo_20130916.git
cd mt7610u_wifi_sta_v3002_dpo_20130916
make
sudo make install
sudo mkdir -p /etc/Wireless/RT2870STA
sudo cp RT2870STA.dat  /etc/Wireless/RT2870STA/RT2870STA.dat
