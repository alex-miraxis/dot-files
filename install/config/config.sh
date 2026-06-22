# Copy over Arch configs
mkdir -p ~/.config
cp -R ~/.local/share/archy/config/* ~/.config/

# Use default bashrc from Arch
cp ~/.local/share/archy/default/bashrc ~/.bashrc
