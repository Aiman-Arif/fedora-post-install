#!/bin/bash

# Define colors
BLUE='\033[0;34m'
WHITE='\033[0;37m'
RED='\033[0;31m'
LOGFILE="setup_log.txt"

# Define user DE
user_de=(
    "GNOME"
    "KDE"
)

# Log function
log() {
    echo -e "$1" | tee -a "$LOGFILE"
}

# Function to improve DNF speed by updating the configuration file
imp_dnf() {
    log "${BLUE}Improving DNF speed${WHITE}"
    cd /etc/dnf || exit
    {
        sudo sed -i '$a fastestmirror=1' dnf.conf
        sudo sed -i '$a max_parallel_downloads=10' dnf.conf
        sudo sed -i '$a deltarpm=True' dnf.conf
        sudo sed -i '$a defaultyes=True' dnf.conf
    } &>> "$LOGFILE"
    if [[ $? -eq 0 ]]; then
        log "${RED}DNF speed improved successfully!${WHITE}"
    else
        log "${RED}Failed to improve DNF speed.${WHITE}"
    fi
}

# Function to add RPM Fusion repositories and update the system
add_rpm_fusion() {
    log "${BLUE}Adding RPM Fusion repositories${WHITE}"
    {
        sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                            https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf groupupdate -y core
        sudo dnf upgrade -y --refresh
    } &>> "$LOGFILE"
    if [[ $? -eq 0 ]]; then
        log "${RED}RPM Fusion repositories added successfully!${WHITE}"
    else
        log "${RED}Failed to add RPM Fusion repositories.${WHITE}"
    fi
}

# Function to update firmware
update_firmware() {
    log "${BLUE}Updating firmware${WHITE}"
    {
        sudo fwupdmgr get-devices
        sudo fwupdmgr refresh --force
        sudo fwupdmgr get-updates
        sudo fwupdmgr update
    } &>> "$LOGFILE"
    if [[ $? -eq 0 ]]; then
        log "${RED}Firmware updated successfully!${WHITE}"
    else
        log "${RED}Failed to update firmware.${WHITE}"
    fi
}

# Function to install media codecs
install_media_codecs() {
    log "${BLUE}Installing media codecs${WHITE}"
    {
        sudo dnf groupupdate -y "core" "multimedia" "sound-and-video" --setopt="install_weak_deps=False" \
                             --exclude="PackageKit-gstreamer-plugin" --allowerasing
        sudo dnf swap -y "ffmpeg-free" "ffmpeg" --allowerasing
        sudo dnf install -y gstreamer1-plugins-{bad-*,good-*,base} gstreamer1-plugin-openh264 gstreamer1-libav \
                            --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
        sudo dnf install -y lame* --exclude=lame-devel
        sudo dnf group upgrade -y --with-optional Multimedia
    } &>> "$LOGFILE"
    if [[ $? -eq 0 ]]; then
        log "${RED}Media codecs installed successfully!${WHITE}"
    else
        log "${RED}Failed to install media codecs.${WHITE}"
    fi
}

# Function to enable hardware video acceleration
enable_hw_video_acceleration() {
    log "${BLUE}Enabling hardware video acceleration${WHITE}"
    {
        sudo dnf install -y ffmpeg ffmpeg-libs libva libva-utils
        sudo dnf config-manager --set-enabled fedora-cisco-openh264
        sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
    } &>> "$LOGFILE"
    if [[ $? -eq 0 ]]; then
        log "${RED}Hardware video acceleration enabled successfully!${WHITE}"
    else
        log "${RED}Failed to enable hardware video acceleration.${WHITE}"
    fi
}

# Function to install commonly used applications
install_commonly_used_apps() {
    log "${BLUE}Installing commonly used applications${WHITE}"
    {
        sudo dnf install -y fastfetch timeshift gnome-console gnome-tweaks vlc
        flatpak install -y com.mattjakeman.ExtensionManager ca.desrt.dconf-editor net.nokyan.Resources
    } &>> "$LOGFILE"
    if [[ $? -eq 0 ]]; then
        log "${RED}Commonly used applications installed successfully!${WHITE}"
    else
        log "${RED}Failed to install commonly used applications.${WHITE}"
    fi
}

# Function to install personal applications for Aiman
personal_apps() {
    log "${BLUE}Installing personal applications for Aiman${WHITE}"
    {
        flatpak remote-add --if-not-exists launcher.moe https://gol.launcher.moe/gol.launcher.moe.flatpakrepo
        sudo dnf copr enable -y geraldosimiao/conky-manager2
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
        dnf check-update
        sudo dnf group install -y "C Development Tools and Libraries" "Development Tools"
        sudo dnf install -y conky-manager2 gnome-shell-extension-pop-shell xprop unzip p7zip p7zip-plugins unrar code
        flatpak install -y com.bitwarden.desktop one.ablaze.floorp io.github.realmazharhussain.GdmSettings io.github.shiftey.Desktop
        flatpak install -y moe.launcher.the-honkers-railway-launcher
    } &>> "$LOGFILE"
    if [[ $? -eq 0 ]]; then
        log "${RED}Personal applications for Aiman installed successfully!${WHITE}"
    else
        log "${RED}Failed to install personal applications for Aiman.${WHITE}"
    fi
}

# Function to remove bloatware
remove_bloatware() {
    log "${BLUE}Removing bloatware${WHITE}"
    {
        sudo dnf remove -y gnome-boxes gnome-connections gnome-contacts gnome-logs gnome-tour mediawriter gnome-abrt \
                         gnome-terminal gnome-system-monitor gnome-extensions-app firefox totem
    } &>> "$LOGFILE"
    if [[ $? -eq 0 ]]; then
        log "${RED}Bloatware removed successfully!${WHITE}"
    else
        log "${RED}Failed to remove bloatware.${WHITE}"
    fi
}

# Function to install themes
setup_theme() {
    log "${BLUE}Installing themes${WHITE}"
    {
        sudo flatpak override --filesystem=$HOME/.themes
        sudo flatpak override --filesystem=$HOME/.icons
        sudo flatpak override --filesystem=xdg-config/gtk-4.0
        sudo dnf install -y gnome-themes-extra gtk-murrine-engine sassc
        cd
        git clone https://github.com/vinceliuice/Colloid-gtk-theme.git
        cd Colloid-gtk-theme
        ./install.sh -t pink --tweaks gruvbox black rimless
        ./install.sh -t pink --tweaks gruvbox black rimless -c dark -l
        cd
        cd .themes
        sudo cp -r ./. /usr/share/themes
        cd
        sudo dnf copr enable -y peterwu/rendezvous
        sudo dnf install -y bibata-cursor-themes
        wget -qO- https://git.io/papirus-icon-theme-install | sh
    } &>> "$LOGFILE"
    if [[ $? -eq 0 ]]; then
        log "${RED}Themes installed successfully!${WHITE}"
    else
        log "${RED}Failed to install themes.${WHITE}"
    fi
}

# Define custom text and corresponding multi-line commands as arrays
custom_ops=(
    "Improve DNF Speed by updating conf file"
    "Adding RPM Fusion"
    "Updating firmware"
    "Installing media codecs"
    "Enabling H/W video acceleration"
    "Installing commonly used apps"
    "Installing personal apps for Aiman"
    "Removing bloatware"
    "Installing themes"
)

custom_commands=(
    "imp_dnf"
    "add_rpm_fusion"
    "update_firmware"
    "install_media_codecs"
    "enable_hw_video_acceleration"
    "install_commonly_used_apps"
    "personal_apps"
    "remove_bloatware"
    "setup_theme"
)

# Function to process selected custom operations
func_proc() {
    local user_de=("${!1}")
    local custom_ops=("${!2}")
    local custom_commands=("${!3}")

    echo "Available DE:"
    for ((i = 0; i < ${#user_de[@]}; i++)); do
        echo "$((i+1)). ${user_de[i]}"
    done

    read -p "Select your Desktop Environment (enter the number only): " select_de
    select_de=${select_de:-1}

    if [ "$select_de" == "1" ]; then
        user_select_de="GNOME"
    else
        user_select_de="KDE"
        custom_commands[7]="sudo dnf remove pim* akonadi* akregator korganizer kolourpaint kmail kmag kmines kmahjongg kmousetool kmouth kpat kruler kamoso krdc krfb ktnef kaddressbook konversation kf5-akonadi-server mariadb mariadb-backup mariadb-common mediawriter gnome-abrt neochat firefox"
    fi

    log "${RED}\nYou will be running ${user_select_de} specific modification!${WHITE}"
    log "${RED}Please close the script if the option is wrong!\n${WHITE}"

    echo "Available commands:"
    for ((i = 0; i < ${#custom_ops[@]}; i++)); do
        echo "$((i+1)). ${custom_ops[i]}"
    done

    read -p "Enter the numbers of the commands to run (separated by spaces), or 'all' to run all commands: " selected_indices
    selected_indices=${selected_indices:-all}

    if [ "$selected_indices" == "all" ]; then
        selected_indices=$(seq -s ' ' 1 ${#custom_ops[@]})
    fi

    IFS=' ' read -ra indices <<< "$selected_indices"

    for index in "${indices[@]}"; do
        if [[ $index =~ ^[0-9]+$ && $index -ge 1 && $index -le ${#custom_ops[@]} ]]; then
            log "\n${BLUE}${custom_ops[index-1]} ${WHITE}"
            eval "${custom_commands[index-1]}"
            log "${RED}Process Completed!${WHITE}\n"
        else
            log "\nInvalid selection: $index\n"
        fi
    done

    sudo dnf upgrade -y --refresh
    sudo dnf autoremove -y

    log "${BLUE}It is recommended to reboot${WHITE}"
    read -p "Press y to continue: " reboot_now
    reboot_now=${reboot_now:-y}

    if [ "$reboot_now" == "y" ]; then
        reboot
    fi
}

# Call the function with arrays of custom text and multi-line commands
func_proc user_de[@] custom_ops[@] custom_commands[@]