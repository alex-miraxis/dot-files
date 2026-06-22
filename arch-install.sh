#!/usr/bin/env bash
#
# arch-install.sh — opinionated, encrypted Arch base installer (replaces archinstall).
#
# Run from the official Arch live ISO, as root, in UEFI mode:
#   1. Connect to the internet (e.g. `iwctl` for Wi-Fi, or just plug in Ethernet).
#   2. pacman -Sy --noconfirm git && git clone https://github.com/alex-miraxis/dot-files.git
#   3. cd dot-files && ./arch-install.sh
#
# It partitions + LUKS-encrypts the target disk, installs a minimal Arch base
# (ext4 inside LUKS, systemd-boot, zram swap, iwd + systemd-networkd + resolved),
# creates your user, then arranges for the Hyprland desktop layer to install
# itself automatically on your first console login. Two reboots total.
#
# THIS ERASES THE TARGET DISK. You will be asked to confirm the disk twice.

set -euo pipefail

# ---- helpers -------------------------------------------------------------
c_grn=$'\e[32m'; c_red=$'\e[31m'; c_ylw=$'\e[33m'; c_rst=$'\e[0m'
say()  { echo -e "${c_grn}==>${c_rst} $*"; }
warn() { echo -e "${c_ylw}==>${c_rst} $*"; }
die()  { echo -e "${c_red}error:${c_rst} $*" >&2; exit 1; }

cleanup() {
  set +e
  mountpoint -q /mnt/boot && umount /mnt/boot
  mountpoint -q /mnt && umount -R /mnt
  [[ -e /dev/mapper/cryptroot ]] && cryptsetup close cryptroot
}
trap 'echo; warn "Aborted/failed (line $LINENO). Cleaning up..."; cleanup; exit 1' ERR

# ---- 0. preflight --------------------------------------------------------
[[ $EUID -eq 0 ]] || die "Run as root from the Arch live ISO."
[[ -d /sys/firmware/efi/efivars ]] || die "UEFI not detected. This installer requires UEFI boot."
ping -c1 -W3 archlinux.org &>/dev/null || die "No internet. Connect first (e.g. iwctl), then re-run."

REPO_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "$REPO_SRC/install.sh" && -d "$REPO_SRC/bin" ]] || die "Run this from inside the cloned repo."

timedatectl set-ntp true 2>/dev/null || true

# ---- 1. gather inputs ----------------------------------------------------
say "Available disks:"
lsblk -dpno NAME,SIZE,MODEL | grep -vE 'loop|/dev/sr|/dev/ram' || true
echo
read -rp "Target disk to ERASE (e.g. /dev/nvme0n1 or /dev/sda): " DISK
[[ -b $DISK ]] || die "Not a block device: $DISK"
warn "ALL DATA on ${DISK} will be DESTROYED."
read -rp "Re-type the disk path to confirm: " CONFIRM
[[ $CONFIRM == "$DISK" ]] || die "Confirmation did not match. Aborting."

read -rp "Hostname [arch]: " HOSTNAME; HOSTNAME=${HOSTNAME:-arch}
while :; do
  read -rp "Username: " USERNAME
  [[ $USERNAME =~ ^[a-z_][a-z0-9_-]*$ ]] && break
  warn "Invalid username (lowercase letters/digits/_/-, must not start with a digit)."
done
DEFAULT_TZ="$(readlink -f /etc/localtime 2>/dev/null | sed 's|.*/zoneinfo/||')"; DEFAULT_TZ=${DEFAULT_TZ:-UTC}
read -rp "Timezone [${DEFAULT_TZ}]: " TIMEZONE; TIMEZONE=${TIMEZONE:-$DEFAULT_TZ}
[[ -f /usr/share/zoneinfo/$TIMEZONE ]] || die "Unknown timezone: $TIMEZONE"

prompt_pass() {  # prompt_pass VARNAME "Prompt"
  local _v _a _b
  while :; do
    read -rsp "$2: " _a; echo
    read -rsp "$2 (again): " _b; echo
    [[ $_a == "$_b" && -n $_a ]] && { printf -v "$1" '%s' "$_a"; break; }
    warn "Mismatch or empty. Try again."
  done
}
prompt_pass LUKS_PASS "Disk encryption (LUKS) passphrase"
prompt_pass USER_PASS "Password for ${USERNAME} (also used for sudo)"

# ---- 2. CPU microcode ----------------------------------------------------
if   grep -q GenuineIntel /proc/cpuinfo; then UCODE_PKG=intel-ucode
elif grep -q AuthenticAMD /proc/cpuinfo; then UCODE_PKG=amd-ucode
else UCODE_PKG=""; fi

# ---- 3. partition --------------------------------------------------------
say "Partitioning ${DISK} (1 GiB EFI + LUKS root)..."
sgdisk --zap-all "$DISK" >/dev/null
wipefs -a "$DISK" >/dev/null 2>&1 || true
sgdisk -n1:0:+1GiB -t1:ef00 -c1:EFI "$DISK" >/dev/null
sgdisk -n2:0:0     -t2:8309 -c2:cryptroot "$DISK" >/dev/null
partprobe "$DISK"; sleep 2

if [[ $DISK == *nvme* || $DISK == *mmcblk* || $DISK == *loop* ]]; then
  ESP="${DISK}p1"; ROOTPART="${DISK}p2"
else
  ESP="${DISK}1"; ROOTPART="${DISK}2"
fi

# ---- 4. LUKS + filesystems ----------------------------------------------
say "Setting up LUKS2 on ${ROOTPART}..."
printf '%s' "$LUKS_PASS" | cryptsetup luksFormat --type luks2 --batch-mode "$ROOTPART" -
printf '%s' "$LUKS_PASS" | cryptsetup open "$ROOTPART" cryptroot -

say "Creating filesystems (FAT32 ESP + ext4 root)..."
mkfs.fat -F32 -n EFI "$ESP" >/dev/null
mkfs.ext4 -qF -L root /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt
mount --mkdir "$ESP" /mnt/boot

# ---- 5. base system ------------------------------------------------------
say "Refreshing mirrors + installing the base system (this takes a while)..."
if command -v reflector &>/dev/null; then
  reflector --latest 20 --sort rate --protocol https --save /etc/pacman.d/mirrorlist 2>/dev/null || true
fi

pacstrap -K /mnt base linux linux-firmware base-devel \
  git sudo vim cryptsetup dosfstools iwd zram-generator ${UCODE_PKG}

genfstab -U /mnt >> /mnt/etc/fstab

# ---- 6. carry the repo + Wi-Fi creds into the new system -----------------
say "Copying this repo into the new system for the merged desktop install..."
install -d -m755 "/mnt/home/$USERNAME/.local/share"
cp -a "$REPO_SRC" "/mnt/home/$USERNAME/.local/share/archy"

if [[ -d /var/lib/iwd ]]; then
  install -d -m700 /mnt/var/lib/iwd
  cp -a /var/lib/iwd/. /mnt/var/lib/iwd/ 2>/dev/null || true   # remember the Wi-Fi you joined on the ISO
fi

# First-login hook: install the desktop layer once, on tty1.
cat > "/mnt/home/$USERNAME/.bash_profile" <<'PROFILE'
[[ -f ~/.bashrc ]] && . ~/.bashrc

# One-time: install the Arch (Hyprland) desktop layer on first console login.
if [[ -f ~/.archy-first-run && "$(tty)" == /dev/tty1 ]]; then
  rm -f ~/.archy-first-run
  echo "Starting the Arch desktop install (AUR steps will pause for review)..."
  ARCHY_ONLINE_INSTALL=true bash ~/.local/share/archy/install.sh
fi
PROFILE
touch "/mnt/home/$USERNAME/.archy-first-run"

# ---- 7. configure the new system (inside chroot) -------------------------
LUKS_UUID="$(blkid -s UUID -o value "$ROOTPART")"
say "Configuring the new system..."
arch-chroot /mnt env \
  TIMEZONE="$TIMEZONE" HOSTNAME="$HOSTNAME" USERNAME="$USERNAME" \
  USER_PASS="$USER_PASS" LUKS_UUID="$LUKS_UUID" \
  bash -s <<'CHROOT'
set -euo pipefail

# time + locale
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc
sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# hostname
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<HOSTS
127.0.0.1 localhost
::1       localhost
127.0.1.1 $HOSTNAME
HOSTS

# initramfs with the LUKS 'encrypt' hook (keyboard before encrypt so you can type the passphrase)
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

# user + sudo (root account locked; use sudo)
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USER_PASS" | chpasswd
passwd -l root
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"

# zram swap (compressed RAM, no disk swap)
cat > /etc/systemd/zram-generator.conf <<ZRAM
[zram0]
zram-size = min(ram / 2, 8192)
compression-algorithm = zstd
ZRAM

# networking: iwd (Wi-Fi) + systemd-networkd (DHCP) + systemd-resolved (DNS)
cat > /etc/systemd/network/20-wired.network <<NET
[Match]
Name=en* eth*
[Network]
DHCP=yes
NET
cat > /etc/systemd/network/20-wireless.network <<NET
[Match]
Name=wl*
[Network]
DHCP=yes
NET
# (resolv.conf symlink is created outside the chroot — see just after CHROOT)
systemctl enable iwd.service systemd-networkd.service systemd-resolved.service

# bootloader: systemd-boot (+ keep its EFI binary updated on systemd upgrades)
bootctl install
systemctl enable systemd-boot-update.service
cat > /boot/loader/loader.conf <<LOADER
default arch.conf
timeout 3
console-mode max
editor no
LOADER
cat > /boot/loader/entries/arch.conf <<ENTRY
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options cryptdevice=UUID=$LUKS_UUID:cryptroot root=/dev/mapper/cryptroot rw
ENTRY
CHROOT

# Point the installed system's resolv.conf at systemd-resolved's stub.
# Done out here on the real on-disk file: inside the chroot the live ISO's
# /etc/resolv.conf already resolves to that stub, so `ln -sf` aborts with
# "are the same file".
rm -f /mnt/etc/resolv.conf
ln -s /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf

# ---- 8. done -------------------------------------------------------------
cleanup
trap - ERR
cat <<DONE

${c_grn}✓ Base install complete.${c_rst}

Next:
  1. Reboot and remove the install media:  ${c_grn}reboot${c_rst}
  2. At boot, enter your LUKS passphrase.
  3. Log in as '${USERNAME}' on the console — the Hyprland desktop install
     starts automatically (the AUR steps will pause for you to review each
     PKGBUILD; see SECURITY.md). It reboots into the Pixie login screen when done.

DONE
