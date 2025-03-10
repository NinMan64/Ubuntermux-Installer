#!/data/data/com.termux/files/usr/bin/bash

PD=$PREFIX/var/lib/proot-distro/installed-rootfs
ds_name=ubuntu

clear

# Colours
R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

## ask() - prompt the user with a message and wait for a Y/N answer
## copied from udroid 
ask() {
    local msg=$*

    echo -ne "$msg\t[y/n]: "
    read -r choice

    case $choice in
        y|Y|yes) return 0;;
        n|N|No) return 1;;
        "") return 0;;
        *) return 1;;
    esac
}

## download_script() - download a script online
download_script() {
    local url=$1
    local dir=$2
    local mode=$3
    
    script=$(echo $url | awk -F / '{print $NF}')

    case $mode in
        verbose) WGET="wget --show-progress" ;;
        silence) WGET="wget -q --show-progress" ;;
        *) WGET="wget" ;;
    esac

    $WGET $url -P $dir
}

# Install proot-distro
requirements() {
    echo "%%%%%%%%%%+              +%%%%%%%%%% Welcome to the UbunTermux Installer!"
    echo "%%%%%+                +%%%    +%%%%% Beta 3 Release 1"
    echo "%%%          -%%%%%%%+%%%%       #%% ©2024-2025 NintendoMan64 Productions."
    echo "%        %%%%%        %%%%%        % Original Project by 23xvx"
    echo "     %%%%%%%+            =%%%-      "
    echo "    %%%%%%%+            =%%%-       "
    echo "%        %%%%%        %%%%%        % Operating System by Cannonical"
    echo "%%%          -%%%%%%%+%%%%       %%% www.ubuntu.com"
    echo "%%%%%*                =%%%    *%%%%%"
    echo "%%%%%%%%%%*              *%%%%%%%%%%"
    sleep 1 
    echo ${G}"Installing required packages..."${W}
    pkg install pulseaudio proot-distro wget  -y
    [[ ! -d "$HOME/storage" ]] && {
        echo ${C}"Please allow storage permission"${W}
        termux-setup-storage
    }
    [[ ! -d "$PREFIX/var/lib/proot-distro" ]] && {
        mkdir -p $PREFIX/var/lib/proot-distro
        mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs
    }
    echo
    [[ -d "$PD/$ds_name" ]] && {
        if ask ${Y}"Overwrite Existing Ubuntu Installation?"${W}; then
            echo ""
            echo ${Y}"Deleting existing directory...."${W}
            proot-distro remove ubuntu || ( echo ${R}"Error 404: Cannot remove existing Install." && exit 1 )
        else
            echo ${R}"Sorry, but we cannot complete the installation, try again!"
            exit 1
        fi
    }
}

# Pick desktop
choose_desktop() {
    clear
    echo ${C}"What Desktop do you want to install?"${Y}
    echo " 1) XFCE (Light Weight)"
    echo " 2) GNOME (Version 47, Ubuntu Version)"
    echo " 3) GNOME (Version 47, Stock Version)"
    echo " 4) MATE (GNOME 2)"
    echo " 5) Windows 10 (KDE with custom themes)"
    echo " 6) Windows 11 (GNOME with custom themes)"
    echo " 7) MacOS (XFCE with custom themes)"
    echo " 8) Cinnamon (GNOME 3, Ubuntu version) "
    echo " 9) Cinnamon (GNOME 3, Stock Version)"
    echo ${C}"Please enter number 1-9 to choose your desktop "
    echo ${C}"If you don't want a desktop please just enter '${W}CLI${C}'"${W}
    read desktop
    sleep 1
    case $desktop in
        1|2|3|4|5|6|7) echo ${G}"Starting Installation..."${Y} ;;
        CLI) echo ${G}"Installing Ubuntu Base (Version 24.04)..."${Y} ;;
        *) echo ${R}"This option dosen't fuck1ng exist"; sleep 1 ; choose_desktop ;;
    esac
}

# Install and Setup ubuntu 
configures() {
    proot-distro install ubuntu
    echo ${G}"Installing ubuntu requirements..."${W}
    cat > $PD/$ds_name/root/.bashrc <<- EOF
    apt-get update
    apt install sudo nano wget openssl git -y
    exit
    echo
EOF
    proot-distro login ubuntu
    rm -rf $PD/$ds_name/root/.bashrc
}

# Ask if setup a user
user() {
    clear
    if ask ${C}"Add user?"${W}; then
        echo ""
        echo ${C}"Please enter a username.: "${W}
        read username
        directory=$PD/$ds_name/home/$username
        login="proot-distro login ubuntu --user $username"
        echo ""
        sleep 1
        echo ${G}"Adding $username..."
        cat > $PD/$ds_name/root/.bashrc <<- EOF
        useradd -m \
            -G sudo \
            -d /home/${username} \
            -k /etc/skel \
            -s /bin/bash \
            $username
        echo $username ALL=\(root\) ALL > /etc/sudoers.d/$username
        chmod 0440 /etc/sudoers.d/$username
        echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        exit
        echo
EOF
        proot-distro login ubuntu
        rm -rf $PD/$ds_name/root/.bashrc
        sleep 2
        [[ ! -d $directory ]] && {
            echo -e ${R}"Failed to add user. using root account!"
            directory=$PD/$ds_name/root
            login="proot-distro login ubuntu"
        }
        clear 
    else
        echo ""
        echo ${G}"Root account will now be used to complete the install!"
        sleep 2
        clear
        directory=$PD/$ds_name/root
        login="proot-distro login ubuntu"
    fi 
}

# install specific desktop
install_desktop() {
    desk=true
    case $desktop in
        1) xfce_mode ;;
        2) gnome_mode ;;
        3) stockgnome_mode ;;
        4) mate_mode ;;
        5) kde_mode ; win10_theme ;;
        6) gnome_mode ; win11_theme ;;
        7) xfce_mode ; macos_theme ;;
        8) ubuntucinnamon_mode ;;
        9) stockcinnamon_mode ;;
        *) echo ${G}"Skipping GUI Install..." ; desk=false ; sleep 2 ;;
    esac
    
    # if desktop is installed, also install external apps
    if $desk ; then 
        apps
    fi
}

# Different mode to download different scripts
xfce_mode() {
    echo ${G}"Installing XFCE Desktop..."${W}
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/xfce.sh" $directory silence
    $login -- /bin/bash xfce.sh
    rm -rf $directory/xfce.sh
}

gnome_mode() {
    echo ${G}"Installing GNOME Desktop, Ubuntu Version...."${W}
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/gnome.sh" $directory silence
    $login -- /bin/bash gnome.sh 
    rm -rf $directory/gnome.sh
}

stockgnome_mode() {
    echo ${G}"Installing GNOME Desktop, Stock Version"${W}
    download_script "https://ia804502.us.archive.org/3/items/utemux-files/gnomestock.sh"
    $login -- /bin/bash gnomestock.sh
    rm -rf $directory/gnomestock.sh
}

mate_mode() {
    echo ${G}"Installing Mate Desktop..."${W}
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/mate.sh" $directory silence
    $login -- /bin/bash mate.sh
    rm -rf $directory/mate.sh
}

kde_mode() {
    echo ${G}"Installing KDE Desktop..."${W}
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/kde.sh" $directory silence
    $login -- /bin/bash kde.sh
    rm -rf $directory/kde.sh
}

cinnamon_mode() {
    echo ${G}"Installing Cinnamon Desktop..."${W}
    download_script "https://ia904502.us.archive.org/3/items/utemux-files/cinnamon.sh" $directory silence
    $login -- /bin/bash cinnamon.sh
    rm -rf $directory/cinnamon.sh
}

stockcinnamon_mode() {
    echo ${G}"Installing Cinnamon Desktop, Stock Version..."
    download_script "https://ia804502.us.archive.org/3/items/utemux-files/cinnamonstock.sh"
    $login -- /bin/bash cinnamonstock.sh
    rm -rf $directory/cinnamonstock.sh
}

win10_theme() {
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Themes/Win10-theme.sh" $directory silence
    $login -- /bin/bash Win10-theme.sh
    rm -rf $directory/Win10-theme.sh
}

win11_theme() {
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Themes/Win11-theme.sh" $directory silence
    $login -- /bin/bash Win11-theme.sh
    rm -rf $directory/Win11-theme.sh
}

macos_theme() {
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Themes/MacOS-theme.sh" $directory silence
    $login -- /bin/bash MacOS-theme.sh
    rm -rf $directory/MacOS-theme.sh
}

# Install external apps
apps() {
    clear

    # Install firefox
    if ask ${C}"Install The Firefox Broswer?"${W}; then
        echo -e ${G}"\Installing Firefox Broswer ...." ${W}
        download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Apps/firefox.sh" $directory silence
        [[ -f $directory/.bashrc ]] && mv $directory/.bashrc $directory/.bak
        cat > $directory/.bashrc <<- EOF
        bash firefox.sh 
        clear 
        vncstart 
        sleep 4
        DISPLAY=:1 firefox-esr &
        sleep 10
        pkill -f firefox-esr
        vncstop
        sleep 2
        exit 
        echo 
EOF
        $login 
        echo 'user_pref("sandbox.cubeb", false);
        user_pref("security.sandbox.content.level", 1);' >> $directory/.mozilla/firefox-esr/*default-esr*/prefs.js
        rm -rf $directory/.bashrc
        mv $directory/.bak $directory/.bashrc
        clear
        sleep 1
    else 
        echo -e ${G}"\nNot installing , skip process..\n"${W}
        sleep 1
    fi

    # Install discord(webcord)
    if ask ${C}"Install Webcord (Discord frontend for Linux)?"${W}; then
        echo -e ${G}"\Installing Webcord...." ${W}
        download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Apps/webcord.sh" $directory silence
        $login -- /bin/bash webcord.sh
        rm $directory/webcord.sh
        clear
    else 
        echo -e ${G}"\nNot installing , skip process..\n" ${W}
        sleep 1
    fi

    # Install VScode
    if ask ${C}"Install Microsoft Visual Studio code?"${W}; then
        echo -e ${G}"\nInstalling MS Vscode ...." ${W}
        download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Apps/vscodefix.sh" $directory silence
        $login -- /bin/bash vscodefix.sh
        rm $directory/vscodefix.sh
    else 
        echo -e ${G}"\nNot installing , skip process..\n" ${W}
        sleep 1
    fi
    clear 
}

# Write startup scripts
fixes() {
    [[ -f $PREFIX/bin/start-ubuntu ]] && rm $PREFIX/bin/start-ubuntu
    echo "pulseaudio \
        --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1'  \
        --exit-idle-time=-1" >> $PREFIX/bin/ubuntu 
    if [[ -z $username ]]; then
        echo "proot-distro login ubuntu --shared-tmp" >> $PREFIX/bin/ubuntu 
    else
        echo "proot-distro login ubuntu --shared-tmp --user $username" >> $PREFIX/bin/ubuntu
    fi
    chmod +x $PREFIX/bin/ubuntu
    [[ ! -f "$directory/.bashrc " ]] && {
        cp $directory/etc/skel/.bashrc $directory
    }
    echo "export PULSE_SERVER=127.0.0.1" >> $directory/.bashrc
}

# End
finish () {
    clear
    sleep 2
    echo ${G}"Installation is now complete!"
    echo ""
    echo " type 'ubuntu'     To Start Ubuntu  "
    echo ""
    [[ $desk == "true" ]] && {
    echo " type 'vncstart'          To start vncserver (In Ubuntu)"
    echo ""
    echo " type 'vncstop'           To stop vncserver (In Ubuntu)"
    echo ""
    }
    echo ${Y}"Notice : You cannot install it by proot-distro after removing it."
    echo ${Q}"Thank you for trying out this beta version of The UTermux Installer!"
    echo ${U}"Credits:"
    echo ${P}"23xvx-original Project"
    echo ${M}"NinMan64-Redistribution, Cinnamon desktop installation bug fix, Added UIs"
    echo ${J}"Send Beta feedback to kianhopebarlas11@gmail.com."
    echo ${J}"Install extras by starting Ubuntu and typing command 'wget https://raw.githubusercontent.com/NinMan64/Ubuntermux-Installer/refs/heads/Files/extras.sh' to install UbunTermux Extras!"
}

# Main program
main () {
    requirements
    choose_desktop
    configures
    user
    install_desktop
    fixes
    finish
}

# call main program
main

