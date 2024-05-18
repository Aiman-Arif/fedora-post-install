#!/bin/bash

# Create a temporary file for Zenity display
temp_file=$(mktemp)

# Create a log file (append mode)
log_file="command_output.log"

# Run multiple commands, duplicate their output to the terminal and the temporary file,
# and also log the output (append mode)
(
    sudo dnf groupupdate -y "core" "multimedia" "sound-and-video" --setopt="install_weak_deps=False" --exclude="PackageKit-gstreamer-plugin" --allowerasing
    sudo dnf swap -y "ffmpeg-free" "ffmpeg" --allowerasing
    sudo dnf install -y gstreamer1-plugins-{bad-*,good-*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
    sudo dnf install -y lame* --exclude=lame-devel
    sudo dnf group upgrade -y --with-optional Multimedia
) | tee "$temp_file" >> "$log_file"

# Display the output in a Zenity text-info dialog
zenity --text-info --title="Command Output" --filename="$temp_file"

# Clean up the temporary file
rm "$temp_file"