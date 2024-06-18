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

# Function to install Papirus icon
install_papirus_icon () {
    # Install Papirus icon theme
    wget -qO- https://git.io/papirus-icon-theme-install | sh
    # Set themes
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
}

# Function to install Bibata cursor
install_bibata_cursor () {
    # Install Bibata cursor theme
    sudo dnf copr enable -y peterwu/rendezvous
    sudo dnf install -y bibata-cursor-themes
    # Set themes
    gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Classic"
}

# Function to install Gruvbox themes
install_gruvbox_theme () {
    sudo dnf install -y gnome-themes-extra gtk-murrine-engine sassc
    cd ~/
    git clone --depth 1 https://github.com/vinceliuice/Colloid-gtk-theme.git
    cd Colloid-gtk-theme
    ./install.sh -t grey --tweaks gruvbox black rimless float
    ./install.sh -t grey --tweaks gruvbox black rimless float -c dark -l
    cd ~/.themes
    sudo cp -r ./. /usr/share/themes
    cd ~/
    # Install Papirus folder icon theme
    wget -qO- https://git.io/papirus-folders-install | sh
    papirus-folders -C grey --theme Papirus-Dark
}

# Function to install Catppuccin themes
install_catppuccin_theme () {
    sudo dnf install -y gnome-themes-extra gtk-murrine-engine sassc
    cd ~/
    git clone --depth 1 https://github.com/vinceliuice/Colloid-gtk-theme.git
    cd Colloid-gtk-theme
    ./install.sh -t purple --tweaks catppuccin black rimless float
    ./install.sh -t purple --tweaks catppuccin black rimless float -c dark -l
    cd ~/.themes
    sudo cp -r ./. /usr/share/themes
    cd ~/
    # Install Papirus folder icon theme
    git clone --depth 1 https://github.com/catppuccin/papirus-folders.git
    cd papirus-folders
    sudo cp -r src/* /usr/share/icons/Papirus
    cd ~/
    wget -qO- https://git.io/papirus-folders-install | sh
    papirus-folders -C cat-mocha-mauve --theme Papirus-Dark
}

# Function to remove all themes
remove_themes () {
    cd ~/.themes
    rm -rf ./Colloid*
    cd ~/.config/gtk-4.0
    rm -rf ./*
    cd /usr/share/themes
    sudo rm -rf ./Colloid*
    cd ~/
    install_papirus_icon
    install_bibata_cursor
}

custom_ops=(
    "Install Papirus icon"
    "Install Bibata cursor"
    "Install Gruvbox GTK themes"
    "Install Catppuccin GTK themes"
    "Remove all GTK themes"
)
custom_commands=(
    "install_papirus_icon"
    "install_bibata_cursor"
    "install_gruvbox_theme"
    "install_catppuccin_theme"
    "remove_themes"
)

# Define the log file
run_log="run_history_theme.log"

# Function to handle Zenity dialogs
yad_dialogs () {
    local custom_ops=("${!1}")
    local custom_commands=("${!2}")
    local desktop_environment=$XDG_CURRENT_DESKTOP

    # Install flathub repository
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    cd ~/
    mkdir .themes .icons
    cd "$current_dir"

    # Override Flatpak filesystem permissions
    sudo flatpak override --filesystem=$HOME/.themes
    sudo flatpak override --filesystem=$HOME/.icons
    sudo flatpak override --filesystem=xdg-config/gtk-4.0

    if [ "$desktop_environment" != "GNOME" ]; then
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
    for selected_option in "${selected_commands[@]}"; do
        for i in "${!custom_ops[@]}"; do
            if [ "${custom_ops[i]}" == "$selected_option" ]; then
                echo -e "\nExecuting: ${custom_ops[i]}"

                eval "${custom_commands[i]}"

                cd "$current_dir"
		        echo "✓ ${custom_ops[i]}" >> "$run_log" # Log the operation

                echo -e "Process Completed!\n"
            fi
        done
    done

    echo -e "○○○○○ All processes completed! Exiting now! ○○○○○\n"
}

# Call the check distribution function
check_distribution
# Call the yad check function
check_yad
# Call the yad dialog function with arrays of custom text and multi-line commands
yad_dialogs custom_ops[@] custom_commands[@]