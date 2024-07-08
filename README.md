POST INSTALL SCRIPT FOR FEDORA 40+
===========================
> [!NOTE]
> - Will be updated after every major update of Fedora Workstation or KDE Spin. Support GNOME and KDE version only.
> - Credits for some part of the script goes to https://github.com/devangshekhawat/Fedora-40-Post-Install-Guide.
> - Credits for install-gnome-extensions script goes to https://github.com/ToasterUwU/install-gnome-extensions.
> - Credits for GTK theme goes to https://github.com/vinceliuice/Colloid-gtk-theme.

> [!IMPORTANT]
> Run the command below to run the script.
> > For setup script:
> ```
> cd ~/
> git clone --depth 1 https://github.com/Aiman217/fedora-gnome-post-install.git
> cd fedora-gnome-post-install
> ./setup.sh
> ```
>
> > For theme script (GNOME Only):
> ```
> cd ~/
> git clone --depth 1 https://github.com/Aiman217/fedora-gnome-post-install.git
> cd fedora-gnome-post-install
> ./theme.sh
> ```

> [!CAUTION]
> This script is made only for personal used and should not be used by other user.

***Option provided in setup script:***
1. Improve DNF Speed by updating conf file
2. Add RPM Fusion
3. Update firmware
4. Install media codecs
5. Install commonly used apps
6. Install personal apps for Aiman
7. Install OhMyBash
8. Remove bloatware
9. Clean up unused packages

***Option provided in theme script (GNOME Only):***
1. Install Papirus icon
2. Install Bibata cursor
3. Install Dracula GTK theme (required Papirus icon)
4. Install Gruvbox GTK theme (required Papirus icon)
5. Install Catppuccin GTK theme (required Papirus icon)
6. Remove all GTK themes
