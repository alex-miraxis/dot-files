# Install the Pixie SDDM theme
archy-refresh-sddm

# Wayland greeter compositor for SDDM (no X needed)
sudo pacman -S --noconfirm --needed weston

# Register the Arch (Hyprland/uwsm) desktop session
sudo mkdir -p /usr/local/share/wayland-sessions
sudo cp "$ARCHY_PATH/default/wayland-sessions/archy.desktop" /usr/local/share/wayland-sessions/archy.desktop

# Configure SDDM: Wayland greeter + Pixie theme. NO autologin — the greeter is
# shown on every boot (that's the whole point of choosing a themed login screen).
sudo mkdir -p /etc/sddm.conf.d
cat <<EOF | sudo tee /etc/sddm.conf.d/10-archy.conf >/dev/null
[General]
DisplayServer=wayland

[Theme]
Current=pixie
EOF

# gnome-keyring auto-unlocks from the SDDM login password via the default
# pam_gnome_keyring lines Arch ships in /etc/pam.d/sddm — nothing to do here.

sudo systemctl enable sddm.service
