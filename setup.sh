#!/bin/bash

# Define custom text and corresponding multi-line commands as arrays
custom_ops=(
  "Improve DNF Speed by updating conf file"
  "Adding RPM Fusion"
  "Updating firmware"
  "Removing bloatware"
  "Installing media codecs"
  "Installing Hoyoverse repo"
  "Installing commonly used apps"
)

imp_dnf () {
  cd
  cd /etc/dnf
  sudo sed -i '$a fastestmirror=1' dnf.conf
  sudo sed -i '$a max_parallel_downloads=10' dnf.conf
  sudo sed -i '$a deltarpm=True' dnf.conf
  sudo sed -i '$a defaultyes=True' dnf.conf
  cd
}

custom_commands=(
  # Improve DNF Speed by updating conf file
  "imp_dnf"
  # Adding RPM Fusion
  "sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm; sudo dnf groupupdate core; sudo dnf update; sudo dnf upgrade --refresh"
  # Updating firmware
  "sudo fwupdmgr get-devices; sudo fwupdmgr refresh --force; sudo fwupdmgr get-updates; sudo fwupdmgr update"
  # Removing bloatware
  "sudo dnf remove -y gnome-boxes gnome-contacts gnome-logs gnome-terminal gnome-tour mediawriter gnome-abrt firefox"
  # Installing media codecs
  "sudo dnf groupupdate 'core' 'multimedia' 'sound-and-video' --setopt='install_weak_deps=False' --exclude='PackageKit-gstreamer-plugin' --allowerasing && sync
  sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing; sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg; sudo dnf install lame\* --exclude=lame-devel; sudo dnf group upgrade --with-optional Multimedia"
  # Installing Hoyoverse repo
  "flatpak remote-add --if-not-exists launcher.moe https://gol.launcher.moe/gol.launcher.moe.flatpakrepo"
  # Installing commonly used apps
  "sudo dnf install gnome-tweaks unzip p7zip p7zip-plugins unrar; flatpak install one.ablaze.floorp io.github.realmazharhussain.GdmSettings com.mattjakeman.ExtensionManager ca.desrt.dconf-editor"
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

  # Print available commands
  echo "Available commands:"
  for ((i = 0; i < ${#custom_ops[@]}; i++)); do
    echo "$((i+1)). ${custom_ops[i]}"
  done

  # Prompt user to select commands
  read -p "Enter the numbers of the commands to run (separated by spaces), or 'all' to run all commands: " selected_indices

  # Check if 'all' was selected
  if [ "$selected_indices" == "all" ]; then
    selected_indices=$(seq 1 ${#custom_ops[@]})
  fi

  # Convert selected indices to array
  IFS=' ' read -ra indices <<< "$selected_indices"

  # Execute selected commands
  for index in "${indices[@]}"; do
    if [[ $index =~ ^[0-9]+$ && $index -ge 1 && $index -le ${#custom_ops[@]} ]]; then
      echo -e "${BLUE}${custom_ops[index-1]} ${WHITE}"
      eval "${custom_commands[index-1]}"
      echo -e "${RED}Process Completed!${WHITE}"
    else
      echo "Invalid selection: $index"
    fi
  done

  sudo dnf upgrade --refresh
  sudo dnf autoremove

  echo -e "${BLUE}It is recommended to reboot${WHITE}"
  read -p "Press y to continue: " reboot_now

  if [ $reboot_now == "y" ];
  then
    reboot
  fi
}

# Call the function with arrays of custom text and multi-line commands
func_proc custom_ops[@] custom_commands[@]
