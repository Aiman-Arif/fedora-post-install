#!/bin/bash

# Function to check if Zenity is installed
check_zenity() {
    if ! command -v zenity &> /dev/null; then
        zenity_missing=$(zenity --question --text="Zenity is not installed. Would you like to install it now?" --ok-label="Yes" --cancel-label="No")
        if [ $? -eq 0 ]; then
            sudo dnf install -y zenity
        else
            echo "Zenity is required to run this script. Exiting."
            exit 1
        fi
    fi
}

# Function to improve DNF speed by updating the configuration file
imp_dnf () {
    cd /etc/dnf
    sudo grep -qxF 'fastestmirror=1' dnf.conf || sudo sed -i '$a fastestmirror=1' dnf.conf
    sudo grep -qxF 'max_parallel_downloads=10' dnf.conf || sudo sed -i '$a max_parallel_downloads=10' dnf.conf
    sudo grep -qxF 'deltarpm=True' dnf.conf || sudo sed -i '$a deltarpm=True' dnf.conf
    sudo grep -qxF 'defaultyes=True' dnf.conf || sudo sed -i '$a defaultyes=True' dnf.conf
}

# Function to add RPM Fusion repositories and update the system
add_rpm_fusion () {
    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf groupupdate -y core
    sudo dnf upgrade -y --refresh
}

# Function to update firmware
update_firmware () {
    sudo fwupdmgr get-devices
    sudo fwupdmgr refresh --force
    sudo fwupdmgr get-updates
    sudo fwupdmgr update
}

# Function to install media codecs
install_media_codecs () {
    sudo dnf groupupdate -y "core" "multimedia" "sound-and-video" --setopt="install_weak_deps=False" --exclude="PackageKit-gstreamer-plugin" --allowerasing
    sudo dnf swap -y "ffmpeg-free" "ffmpeg" --allowerasing
    sudo dnf install -y gstreamer1-plugins-{bad-*,good-*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
    sudo dnf install -y lame* --exclude=lame-devel
    sudo dnf group upgrade -y --with-optional Multimedia
}

# Function to enable hardware video acceleration
enable_hw_video_acceleration () {
    sudo dnf install -y ffmpeg ffmpeg-libs libva libva-utils
    sudo dnf config-manager --set-enabled fedora-cisco-openh264
    sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
}

# Function to install commonly used applications
install_commonly_used_apps () {
    sudo dnf install -y fastfetch timeshift gnome-console gnome-tweaks vlc
    flatpak install -y com.mattjakeman.ExtensionManager ca.desrt.dconf-editor net.nokyan.Resources
}

# Function to install personal applications for Aiman
personal_apps () {
    flatpak remote-add --if-not-exists launcher.moe https://gol.launcher.moe/gol.launcher.moe.flatpakrepo
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    dnf check-update
    sudo dnf group install -y "C Development Tools and Libraries" "Development Tools"
    sudo dnf install -y unzip p7zip p7zip-plugins unrar code
    flatpak install -y com.bitwarden.desktop one.ablaze.floorp io.github.shiftey.Desktop
    flatpak install -y moe.launcher.the-honkers-railway-launcher
}

# Function to remove bloatware
remove_bloatware () {
    sudo dnf remove -y gnome-boxes gnome-connections gnome-contacts gnome-logs gnome-tour mediawriter gnome-abrt gnome-terminal gnome-system-monitor gnome-extensions-app firefox totem
}

# Function to install themes
setup_theme () {
    sudo flatpak override --filesystem=$HOME/.themes
    sudo flatpak override --filesystem=$HOME/.icons
    sudo flatpak override --filesystem=xdg-config/gtk-4.0
    sudo dnf copr enable -y geraldosimiao/conky-manager2
    sudo dnf install -y gnome-themes-extra gtk-murrine-engine sassc conky-manager2 gnome-shell-extension-pop-shell xprop
    flatpak install -y io.github.realmazharhussain.GdmSettings
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

# Define custom commands as function names
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

# Define user DE
user_de=("GNOME" "KDE")

# Function to handle Zenity dialogs
zenity_dialogs () {
    local user_de=("${!1}")
    local custom_ops=("${!2}")
    local custom_commands=("${!3}")

    # Select DE using Zenity
    user_select_de=$(zenity --list --title="Select Your Desktop Environment" --column="DE" "${user_de[@]}" --height=200 --width=300)

    # Modify commands for KDE
    if [ "$user_select_de" == "KDE" ]; then
        # Installing commonly used apps
        custom_commands[5]="sudo dnf install -y fastfetch timeshift vlc; flatpak install -y net.nokyan.Resources"
        # Removing bloatware
        custom_commands[7]="sudo dnf remove -y pim* akonadi* akregator korganizer kolourpaint kmail kmag kmines kmahjongg kmousetool kmouth kpat kruler kamoso krdc krfb ktnef kaddressbook konversation kf5-akonadi-server mariadb mariadb-backup mariadb-common mediawriter gnome-abrt neochat firefox"
        # Removing the setup_theme function for KDE
        unset 'custom_ops[8]'
        unset 'custom_commands[8]'  
    fi

    zenity --info --text="You will be running ${user_select_de} specific modification! Please close the script if the option is wrong!"

    # Add "Select All" option to custom_ops
    custom_ops=("Select All" "${custom_ops[@]}")

    # Select commands to run using Zenity with multi-select option
    selected_indices=$(zenity --list --title="Select Commands to Run: Multi Select using Ctrl + Alt" --column="Commands" "${custom_ops[@]}" --multiple --height=400 --width=600)

    if [ -z "$selected_indices" ]; then
        zenity --error --text="No commands selected. Exiting."
        exit 1
    fi

    # Convert selected options to indices
    IFS='|' read -ra indices <<< "$selected_indices"

    # Check if "Select All" was chosen
    if [[ " ${indices[@]} " =~ " Select All " ]]; then
        indices=("${custom_ops[@]:1}")  # Select all options excluding "Select All"
    fi

    # Show selected options in an info message
    zenity --info --text="Your selected options: ${indices[*]}"

    # Execute selected commands
    for selected_option in "${indices[@]}"; do
        for ((i = 1; i < ${#custom_ops[@]}; i++)); do
            if [ "${custom_ops[i]}" == "$selected_option" ]; then
                echo -e "\nExecuting: ${custom_ops[i]}"
                eval "${custom_commands[i-1]}"  # Adjust index for command
                echo -e "Process Completed!\n"
            fi
        done
    done

    sudo dnf upgrade -y --refresh
    sudo dnf autoremove -y

    zenity --question --text="It is recommended to reboot. Reboot now?" --ok-label="Yes" --cancel-label="No"
    if [ $? -eq 0 ]; then
        reboot
    fi
}

# Call the zenity check function
check_zenity
# Call the Zenity dialog function with arrays of custom text and multi-line commands
zenity_dialogs user_de[@] custom_ops[@] custom_commands[@]