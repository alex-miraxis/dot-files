gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue"

# Fonts: UI = Space Grotesk (fall back to Inter if it wasn't installed),
# monospace = JetBrains Mono Nerd Font.
if fc-list 2>/dev/null | grep -qi "Space Grotesk"; then
  ui_font="Space Grotesk 11"
else
  ui_font="Inter 11"
fi
gsettings set org.gnome.desktop.interface font-name "$ui_font"
gsettings set org.gnome.desktop.interface document-font-name "$ui_font"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 10"

sudo gtk-update-icon-cache /usr/share/icons/Yaru 2>/dev/null || true
