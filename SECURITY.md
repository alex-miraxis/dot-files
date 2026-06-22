# Security — installing from the AUR safely

You asked to flag recent AUR incidents so this setup doesn't pull malware. Here's
the situation and exactly what the installer does about it.

## Why this matters

Packages in the **official Arch repos** (`core`/`extra`/`multilib`) are
PGP-signed and maintainer-vetted. The **AUR** is user-submitted, unsigned, and
runs arbitrary `PKGBUILD`/`.install` code on your machine at build time. It has
been a real malware vector:

| When | Incident | What happened |
|------|----------|---------------|
| **Jul 2025** | **CHAOS RAT** | Malicious packages `librewolf-fix-bin`, `firefox-patch-bin`, `zen-browser-patched-bin` (uploader `danikpapas`) pulled a remote-access trojan from a personal GitHub repo during `makepkg`. Live ~46h. |
| **Aug 2025** | **Spark RAT** | A fake `google-chrome-stable` whose `.install` script downloaded + ran remote code on every launch. |
| **Jun 2026** | **"Atomic Arch"** (ongoing) | ~400→1,500+ **orphaned/abandoned** AUR packages were adopted and backdoored to run an `npm install` of a malicious package (`atomic-lockfile` / `js-digest`) that dropped a credential-stealer + eBPF rootkit. The official repos were **not** affected; Arch temporarily disabled new AUR account registration. |

**Key fact:** Atomic Arch only hit *orphaned* packages. Every AUR package this
repo installs is actively maintained and pulls from its genuine, official
upstream — none were in the blast radius (verified Jun 2026).

## What the installer does

1. **Signed repos first.** Anything available in `core`/`extra`/`multilib` is
   installed with `pacman` (signed). See `install/archy-base.packages`.
   Notably `zed`, `bitwarden`, `telegram-desktop`, `vlc`, `inter-font` come from
   the signed repos, **not** the AUR.
2. **AUR is quarantined to a short, explicit list** in
   `install/archy-aur.packages`, each annotated with its official upstream.
3. **PKGBUILD review is ON by default** for AUR builds (`archy-pkg-aur-add`
   runs `yay -S` *without* `--noconfirm`). You see and approve every PKGBUILD,
   `.install` hook, and source diff before anything builds. `archy-aur-notice`
   prints a reminder first. Set `ARCHY_AUR_TRUST=1` only for trusted, unattended
   runs.
4. **`yay` is bootstrapped from the official AUR** (`yay-bin`) and **built as a
   normal user**, never root.

## The AUR packages this repo installs (and why each is trusted)

| Package | Upstream source | Note |
|---------|-----------------|------|
| `helium-browser-bin` | `imputnet/helium-linux` releases | PGP-verified in PKGBUILD |
| `walker-bin` | `abenz1267/walker` | launcher (upstream author) |
| `elephant-all-bin` | `abenz1267/elephant` | walker data providers (maintained by the author) |
| `1password` / `1password-cli` | `downloads.1password.com` / AgileBits | vendor-maintained, signed |
| `slack-desktop` | `slack.com/downloads` | 600+ votes, long-standing |
| `onlyoffice-bin` | `onlyoffice.com` | reputable maintainer |
| `localsend-bin` | `localsend/localsend` releases | |
| `claude-desktop-native` | builds from Anthropic's **official** installer | unofficial Linux packaging of Anthropic's app |
| `otf-space-grotesk` | Florian Karsten / Google Fonts | UI font |
| `tzupdate`, `ufw-docker`, `xdg-terminal-exec`, `yaru-icon-theme`, `python-terminaltexteffects` | respective official upstreams | small utilities |

## When you review a PKGBUILD, reject anything that…

- uses a **`source=`** that isn't the genuine vendor/upstream domain (a random
  personal GitHub is the CHAOS RAT pattern);
- runs **network calls at build/install time**: `curl|sh`, `wget … | bash`,
  `npm/pip/bun install`, `git clone` of an odd repo, `base64 -d | sh`;
- puts logic in `prepare()/build()/package()` or `.install` hooks beyond moving
  files;
- ships `sha256sums=('SKIP')` on a binary source.

`yay` (v13+) also shows each PKGBUILD's last-modified age — a freshly-modified
PKGBUILD on an old, previously-trusted package is the Atomic Arch signature.

## Sources
- Arch advisory (CHAOS RAT): https://lists.archlinux.org/archives/list/aur-general@lists.archlinux.org/thread/7EZTJXLIAQLARQNTMEW2HBWZYE626IFJ/
- Arch news (Atomic Arch): https://archlinux.org/news/active-aur-malicious-packages-incident/
- BleepingComputer, Sonatype, StepSecurity write-ups of the above.
