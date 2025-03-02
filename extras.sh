apt upgrade -y
echo "Installing wallpapers..."
sleep 1
apt install ubuntu-wallpapers ubuntu-wallpapers-bionic ubuntu-wallpapers-dapper ubuntu-wallpapers-focal ubuntu-wallpapers-hardy ubuntu-wallpapers-jammy ubuntu-wallpapers-lucid ubuntu-wallpapers-precise ubuntu-wallpapers-trusty ubuntu-wallpapers-yakkety ubuntu-wallpapers-xenial ubuntu-wallpapers-karmic -y 
echo "Note: these are not all of the ubuntu wallpapapers. Install the rest yourself!!!"
sleep 1
clear
echo "Installing extra applications..."
sleep 1
apt install blender gnome-games gdebi gedit gimp inkscape kdenlive krita lollypop obs-studio thunderbird vim -y
sleep 1
echo "Installing extra applications VIA wget..."
sleep 1
wget https://raw.githubusercontent.com/wahasa/Ubuntu/main/Apps/chromiumfix.sh ; chmod +x chromiumfix.sh ; ./chromiumfix.sh
wget https://raw.githubusercontent.com/wahasa/Ubuntu/main/Apps/libreofficefix.sh ; chmod +x libreofficefix.sh ; ./libreofficefix.sh
wget https://raw.githubusercontent.com/wahasa/Ubuntu/main/Apps/vscodefix.sh ; chmod +x vscodefix.sh ; ./vscodefix.sh
echo "Done!"
rm -rf $HOME/extras.sh
