#!/bin/bash

# Online (curl-piped) installer entry point for Arch.
export ARCHY_ONLINE_INSTALL=true

ansi_art='   █████╗ ██████╗  ██████╗██╗  ██╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║
  ███████║██████╔╝██║     ███████║
  ██╔══██║██╔══██╗██║     ██╔══██║
  ██║  ██║██║  ██║╚██████╗██║  ██║
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝'

clear
echo -e "\n$ansi_art\n"

# Override these if you fork the repo or track a branch.
ARCHY_REPO="${ARCHY_REPO:-alex-miraxis/dot-files}"
ARCHY_REF="${ARCHY_REF:-main}"

sudo pacman -Sy --noconfirm --needed git

echo -e "\nCloning Arch from: https://github.com/${ARCHY_REPO}.git (branch: ${ARCHY_REF})"
rm -rf ~/.local/share/archy/
git clone "https://github.com/${ARCHY_REPO}.git" ~/.local/share/archy >/dev/null
if [[ $ARCHY_REF != "main" ]]; then
  git -C ~/.local/share/archy fetch origin "$ARCHY_REF" && git -C ~/.local/share/archy checkout "$ARCHY_REF"
fi

echo -e "\nInstallation starting..."
source ~/.local/share/archy/install.sh
