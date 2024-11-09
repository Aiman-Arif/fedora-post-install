#!/bin/bash

current_dir=$(pwd)

# Function to check if the distribution is Fedora
check_distribution() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release  # Load OS release information
        if [[ "${ID}" != "fedora" ]]; then
            echo "Error: This script is intended for Fedora Linux. Detected distribution: ${ID}"
            exit 1
        fi
    else
        echo "Error: /etc/os-release not found. Cannot determine distribution."
        exit 1
    fi
}

# Function to check if YAD is installed
check_yad() {
    if ! command -v yad &> /dev/null; then
        echo -e "\nExecuting: Installing YAD"
        sudo dnf install -y yad  # Install YAD if not already installed
        echo -e "Process Completed!\n"
    fi
}

# Function to improve DNF speed by updating the configuration file
imp_dnf() {
    local dnf_conf="/etc/dnf/dnf.conf"
    # Add settings to dnf.conf if they do not already exist
    sudo grep -qxF 'max_parallel_downloads=10' $dnf_conf || echo 'max_parallel_downloads=10' | sudo tee -a $dnf_conf
    sudo grep -qxF 'defaultyes=True' $dnf_conf || echo 'defaultyes=True' | sudo tee -a $dnf_conf
}

# Function to add RPM Fusion repositories and update the system
add_rpm_fusion () {
    # Install RPM Fusion repositories
    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf group upgrade -y core  # Upgrade all packages
}

# Function to update firmware
update_firmware () {
    sudo fwupdmgr refresh --force  # Refresh metadata
    sudo fwupdmgr get-devices  # Get list of devices
    sudo fwupdmgr get-updates  # Get list of updates
    sudo fwupdmgr update  # Apply updates
}

# Function to install media codecs
install_media_codecs () {
    sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
    sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
}

# Function to install commonly used applications for GNOME
install_commonly_used_apps_gnome () {
    # Install applications via DNF and Flatpak
    sudo dnf install -y fastfetch gnome-tweaks btop
    flatpak install -y io.github.realmazharhussain.GdmSettings com.mattjakeman.ExtensionManager ca.desrt.dconf-editor com.github.rafostar.Clapper io.github.zen_browser.zen
}

# Function to install commonly used applications for KDE
install_commonly_used_apps_kde () {
    # Install applications via DNF
    sudo dnf install -y fastfetch btop
    flatpak install -y io.github.zen_browser.zen
}

# Function to install personal applications for Aiman
personal_apps () {
    # Install development tools and other applications
    sudo dnf group install -y c-development development-tools
    flatpak install -y io.github.shiftey.Desktop org.telegram.desktop org.gnome.gThumb
    # Add launcher.moe Flatpak repository and Microsoft GPG key
    flatpak remote-add --if-not-exists launcher.moe https://gol.launcher.moe/gol.launcher.moe.flatpakrepo
    flatpak install -y moe.launcher.the-honkers-railway-launcher
}

# Function to install personal extensions for Aiman
personal_extensions () {
    # Install required dependencies
    sudo dnf install -y curl wget jq
    # Install extensions
    cd "$current_dir"
    ./install-gnome-extensions.sh --enable --file ./extensions.txt
    cd ~/
}

# Function to remove bloatware
remove_bloatware () {
    # Remove unwanted applications
    sudo dnf remove -y gnome-boxes gnome-connections gnome-contacts gnome-logs gnome-tour mediawriter gnome-abrt gnome-system-monitor gnome-extensions-app totem firefox
    sudo dnf install -y systemd-container
}

# Function to run after scripts completed
clean_up () {
    sudo dnf upgrade -y --refresh  # Upgrade all packages
    sudo dnf autoremove -y  # Remove unnecessary packages
}

# Define custom text and corresponding multi-line commands as arrays
custom_ops=(
    "Improve DNF Speed by updating conf file"
    "Add RPM Fusion"
    "Update firmware"
    "Install media codecs"
    "Install commonly used apps"
    "Install personal apps for Aiman"
    "Install personal extensions for Aiman"
    "Remove bloatware"
    "Clean up unused packages"
)

# Define custom commands as function names
custom_commands=(
    "imp_dnf"
    "add_rpm_fusion"
    "update_firmware"
    "install_media_codecs"
    "install_commonly_used_apps_gnome"
    "personal_apps"
    "personal_extensions"
    "remove_bloatware"
    "clean_up"
)

# Define the log file
run_log="run_history_setup.log"

# Function to handle Zenity dialogs
yad_dialogs () {
    local custom_ops=("${!1}")
    local custom_commands=("${!2}")
    local desktop_environment=$XDG_CURRENT_DESKTOP

    # Install flathub repository
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    # Modify commands for KDE
    if [ "$desktop_environment" == "KDE" ]; then
        local hide_index=6
        unset 'custom_ops[${hide_index}]'
        unset 'custom_commands[${hide_index}]'
        for ((i=${hide_index}; i<${#custom_ops[@]}-1; i++)); do
            custom_ops[i]=${custom_ops[i+1]}
        done
        unset 'custom_ops[${#custom_ops[@]}-1]'
        for ((i=${hide_index}; i<${#custom_commands[@]}-1; i++)); do
            custom_commands[i]=${custom_commands[i+1]}
        done
        unset 'custom_commands[${#custom_commands[@]}-1]'

        custom_commands[4]=install_commonly_used_apps_kde
        custom_commands[6]="sudo dnf remove -y firefox pim* akonadi* akregator korganizer kolourpaint kmail kmines kmahjongg kmousetool kmouth kpat kamoso krdc krfb ktnef kaddressbook mariadb mariadb-backup mariadb-common mediawriter gnome-abrt neochat"
    elif [ "$desktop_environment" != "GNOME" ]; then
        echo "Error: Your desktop environment is not supported."
        exit 1
    fi

    # Show the form and capture the output
    selected_indices=$(
        yad_command=(yad --form --title="Select Commands to Run" --text="Please select the commands you want to run:" --separator="|" --width=500 --height=500)
        for cmd in "${custom_ops[@]}"; do
            yad_command+=(--field="$cmd:CHK")
        done
        "${yad_command[@]}"
    )

    # Check if the user canceled the dialog
    if [ $? -ne 0 ]; then
        echo "No commands selected. Exiting."
        exit 1
    fi

    # Process the selected indices
    IFS="|" read -r -a selected_flags <<< "$selected_indices"

    # Extract the selected commands based on checkbox flags
    selected_commands=()
    for i in "${!selected_flags[@]}"; do
        if [ "${selected_flags[i]}" == "TRUE" ]; then
            selected_commands+=("${custom_ops[i]}")
        fi
    done

    # Show selected options
    if [ ${#selected_commands[@]} -eq 0 ]; then
        yad --error --text="No commands selected. Exiting." --width=300 --height=150
        exit 1
    fi


    # Check if the log file exists and remove it if it does
    if [ -f "$run_log" ]; then
        rm "$run_log"  # Remove the existing log file
    fi

    # Execute selected commands
    for i in "${!selected_commands[@]}"; do
        local currect_commands_index=$(($i + 1))
        for j in "${!custom_ops[@]}"; do
            if [ "${custom_ops[j]}" == "${selected_commands[i]}" ]; then
                echo -e "\nExecuting [${currect_commands_index}/${#selected_commands[@]}]: ${custom_ops[j]}"

                eval "${custom_commands[j]}"

                cd "$current_dir"
		        echo "[${currect_commands_index}] ${custom_ops[j]}" >> "$run_log" # Log the operation

                break
            fi
        done
    done

    echo -e "○○○○○ All processes completed! Total commands run: [${#selected_commands[@]}] ○○○○○\n"

    yad --question --text="It is recommended to reboot. Reboot now?" --button="No:0" --button="Yes:1" --width=300 --height=150
    if [ $? -eq 1 ]; then
        reboot  # Reboot the system if the user agrees
    fi
}

# Call the check distribution function
check_distribution
# Call the yad check function
check_yad
# Call the yad dialog function with arrays of custom text and multi-line commands
yad_dialogs custom_ops[@] custom_commands[@]
