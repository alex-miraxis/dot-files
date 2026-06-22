if [[ -n ${ARCHY_ONLINE_INSTALL:-} ]]; then
  # Build tools required to build AUR packages
  sudo pacman -Sy --noconfirm --needed base-devel git

  # Make sure the official keyring is current before installing anything
  sudo pacman -S --noconfirm --needed archlinux-keyring

  # Enable the [multilib] repo (needed for 32-bit libs, e.g. NVIDIA / gaming)
  if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    echo "Enabling [multilib] repo..."
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
  fi

  sudo pacman -Syu --noconfirm

  # Bootstrap the AUR helper (yay) from the OFFICIAL AUR if it's missing.
  # Built as the current unprivileged user (never as root).
  if ! command -v yay &>/dev/null; then
    echo "Bootstrapping yay from the AUR..."
    tmp="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
  fi
fi
