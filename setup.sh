#!/bin/bash
BLUE='\033[0;34m'
WHITE='\033[0;37m' 
RED='\033[0;31m'

# Improve DNF Speed
echo -e "${BLUE}Improve DNF Speed by updating conf file${WHITE}"
read -p "Press y to continue: " imp_DNF

if [ $imp_DNF == "y" ];
then
  cd
  cd /etc/dnf
  sudo sed -i '$a fastestmirror=1' dnf.conf
  sudo sed -i '$a max_parallel_downloads=10' dnf.conf
  sudo sed -i '$a deltarpm=True' dnf.conf
  sudo sed -i '$a defaultyes=True' dnf.conf
  cd
fi

# Add RPM Fusion
echo -e "${BLUE}Adding RPM Fusion${WHITE}"
read -p "Press y to continue: " add_RPM

if [ $add_RPM == "y" ];
then
  sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  sudo dnf groupupdate core
fi

# Update DNF
echo -e "${BLUE}Updating DNF${WHITE}"
read -p "Press y to continue: " up_DNF

if [ $up_DNF == "y" ];
then
  sudo dnf update
  sudo dnf upgrade --refresh
fi

# Update Firmware
echo -e "${BLUE}Updating firmware${WHITE}"
read -p "Press y to continue: " up_firm

if [ $up_firm == "y" ];
then
  sudo fwupdmgr get-devices 
  sudo fwupdmgr refresh --force 
  sudo fwupdmgr get-updates 
  sudo fwupdmgr update
fi

# Install Media Codecs
echo -e "${BLUE}Installing media codecs${WHITE}"
read -p "Press y to continue: " in_codecs

if [ $in_codecs == "y" ];
then
  sudo dnf groupupdate 'core' 'multimedia' 'sound-and-video' --setopt='install_weak_deps=False' --exclude='PackageKit-gstreamer-plugin' --allowerasing && sync
  sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing
  sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
  sudo dnf install lame\* --exclude=lame-devel
  sudo dnf group upgrade --with-optional Multimedia
fi

# Install Rar support
echo -e "${BLUE}Installing Rar support${WHITE}"
read -p "Press y to continue: " in_rar

if [ $in_rar == "y" ];
then
  sudo dnf install -y unzip p7zip p7zip-plugins unrar
fi

# Install hoyoverse repo
echo -e "${BLUE}Installing Hoyoverse repo${WHITE}"
read -p "Press y to continue: " in_hoyo

if [ $in_hoyo == "y" ];
then
  flatpak remote-add --if-not-exists launcher.moe https://gol.launcher.moe/gol.launcher.moe.flatpakrepo
fi

# Remove bloatware
echo -e "${BLUE}Removing bloatware${WHITE}"
read -p "Press y to continue: " remove_bloat

if [ $remove_bloat == "y" ];
then
  sudo dnf remove -y gnome-boxes gnome-contacts gnome-logs gnome-terminal gnome-tour mediawriter gnome-abrt firefox
fi

# Install commonly used apps
echo -e "${BLUE}Installing commonly used apps${WHITE}"
read -p "Press y to continue: " in_apps

if [ $in_apps == "y" ];
then
  sudo dnf install gnome-tweaks
  flatpak install one.ablaze.floorp io.github.realmazharhussain.GdmSettings com.mattjakeman.ExtensionManager ca.desrt.dconf-editor
fi

# Clean setup before exiting
sudo dnf upgrade --refresh
sudo dnf autoremove

# Restart
echo -e "${BLUE}It is recommended to restart${WHITE}"
read -p "Press y to continue: " re

if [ $re == "y" ];
then
  reboot
fi