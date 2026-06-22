# Arch

A personal, de-branded take on a beautiful, modern Hyprland desktop for Arch
Linux — plus a one-shot installer to reproduce it on any fresh Arch box.

It keeps the excellent out-of-the-box experience of
[Omarchy](https://github.com/basecamp/omarchy) (Hyprland, Waybar, Walker,
notifications, lock/idle, screenshots, the theming engine, the `archy` command
suite) while stripping the Omarchy name, logo and bloat, and swapping in my own
app choices.

## Install

### From scratch (replaces archinstall)

Boot the official Arch ISO (UEFI), connect to the internet (e.g. `iwctl`), then:

```bash
pacman -Sy --noconfirm git
git clone https://github.com/alex-miraxis/dot-files.git
cd dot-files
./arch-install.sh
```

`arch-install.sh` LUKS-encrypts and partitions the disk you choose (ext4 root +
1 GiB EFI), installs a minimal base (systemd-boot, zram swap, iwd +
systemd-networkd + resolved), creates your user, and copies this repo in. It
carries your ISO Wi-Fi credentials forward. Reboot, unlock the disk, and log in
on the console — the **Hyprland desktop layer installs itself** on first login
(AUR steps pause for review), then reboots into the Pixie greeter. Two reboots
total.

### Desktop layer only (already running vanilla Arch)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alex-miraxis/dot-files/main/boot.sh)
```

This clones the repo to `~/.local/share/archy` and runs `install.sh`. Re-running
is safe (idempotent).

> **Heads up — the AUR.** A handful of apps aren't in the official repos and are
> built from the AUR. Because the AUR is unsigned and has been a real malware
> vector, the installer enables **PKGBUILD review** for every AUR build. Read
> [SECURITY.md](SECURITY.md) before installing, and actually look at the diffs
> when prompted. (`ARCHY_AUR_TRUST=1` skips review for unattended runs.)


## What's in it

- **Compositor / desktop:** Hyprland (Lua config), Waybar, Walker + Elephant,
  Mako, hyprlock/hypridle, swaybg/swayosd, grim/slurp/satty screenshots,
  the `tte` screensaver — all the Omarchy goodies, de-branded.
- **Terminal:** Ghostty · **File manager:** Nautilus · **Browser:** Helium
  (also the web-app `--app` backend, so no Chromium).
- **Editors:** Neovim (LazyVim, theme-aware) + Zed.
- **Dev:** Docker + lazydocker; Node, Python, Go, Rust via `mise`;
  Claude Code, Codex CLI.
- **Apps:** Slack, Telegram, 1Password + Bitwarden, OnlyOffice, VLC,
  LocalSend, Claude Desktop.
- **Web apps:** YouTube Music, Notion, ChatGPT, WhatsApp, GitHub.
- **Login:** SDDM with the [Pixie](https://github.com/xCaptaiN09/pixie-sddm)
  theme (Wayland greeter via weston, no autologin).
- **Fonts:** UI = Space Grotesk (Inter fallback), mono = JetBrains Mono Nerd.
- **Display:** tuned for a 3440×1440 ultrawide (scale 1).
- **Themes:** all 21 bundled themes; default Tokyo Night. Switch with
  `archy theme set "<name>"`.

## The `archy` command

Everything Omarchy did under `omarchy` is now `archy` (and `archy-*`):
`archy theme set "Nord"`, `archy update`, `archy menu` (also Super+Alt+Space /
the Waybar logo), `archy gdrive setup` (mount Google Drive via rclone), etc.

## Notes / scope

- This is a **post-install desktop layer**, not an ISO. Install Arch yourself
  (e.g. `archinstall`) with your own disk encryption (LUKS) and bootloader, then
  run the script. There is intentionally **no Plymouth/Limine/Snapper** wiring —
  it boots like plain Arch.
- A few macOS/Windows-only apps (Granola, the Codex desktop app, Logi Tune)
  have no trustworthy native Linux build and are deliberately omitted.

## Credits

De-branded fork of **Omarchy** by David Heinemeier Hansson (MIT). Bundles the
**Pixie SDDM** theme by xCaptaiN09 (MIT). See [LICENSE](LICENSE).
