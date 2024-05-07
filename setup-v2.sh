#!/bin/bash

# Define custom text and corresponding multi-line commands as arrays
custom_ops=(
  "Improve DNF Speed by updating conf file"
  "Adding RPM Fusion"
  "Updating DNF"
  "Updating firmware"
  "Installing media codecs"
  "Installing Rar support"
  "Installing Hoyoverse repo"
  "Removing bloatware"
  "Installing commonly used apps"
  "Removing unused dependencies"
  "It is recommended to restart"
)

custom_commands=(
  "cd; cd /etc/dnf; sudo sed -i '$a fastestmirror=1' dnf.conf; sudo sed -i '$a max_parallel_downloads=10' dnf.conf; sudo sed -i '$a deltarpm=True' dnf.conf; sudo sed -i '$a defaultyes=True' dnf.conf; cd"
  "sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm: sudo dnf groupupdate core"
  "sudo dnf update; sudo dnf upgrade --refresh"
  "sudo fwupdmgr get-devices; sudo fwupdmgr refresh --force; sudo fwupdmgr get-updates; sudo fwupdmgr update"
  "sudo dnf groupupdate 'core' 'multimedia' 'sound-and-video' --setopt='install_weak_deps=False' --exclude='PackageKit-gstreamer-plugin' --allowerasing && sync
  sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing; sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg; sudo dnf install lame\* --exclude=lame-devel; sudo dnf group upgrade --with-optional Multimedia"
  "sudo dnf install -y unzip p7zip p7zip-plugins unrar"
  "flatpak remote-add --if-not-exists launcher.moe https://gol.launcher.moe/gol.launcher.moe.flatpakrepo"
  "sudo dnf remove -y gnome-boxes gnome-contacts gnome-logs gnome-terminal gnome-tour mediawriter gnome-abrt firefox"
  "sudo dnf install gnome-tweaks; flatpak install one.ablaze.floorp io.github.realmazharhussain.GdmSettings com.mattjakeman.ExtensionManager ca.desrt.dconf-editor"
  "sudo dnf upgrade --refresh; sudo dnf autoremove"
  "reboot"
)

# Define your function
func_proc () {
  # Extract custom text and commands from function arguments
  local custom_ops=("${!1}")  # Indirect reference to array variable
  local custom_commands=("${!2}")  # Indirect reference to array variable

  # Define colors
  BLUE='\033[0;34m'
  WHITE='\033[0;37m'
  RED='\033[0;31m'

  # Loop through each custom text and command pair
  for ((i = 0; i < ${#custom_ops[@]}; i++)); do
    # Print custom text
    echo -e "${BLUE}${custom_ops[i]} ${WHITE}"

    # Prompt user for input
    read -p "Press y to continue: " input

    # Check user input
    if [ "$input" == "y" ]; then
      # Execute corresponding multi-line custom command
      eval "${custom_commands[i]}"
      echo -e "${RED}Process Completed!${WHITE}"
    fi
  done
}

# Call the function with arrays of custom text and multi-line commands
func_proc custom_ops[@] custom_commands[@]
