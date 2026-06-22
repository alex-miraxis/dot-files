# Install AUR packages. Run interactively, archy-pkg-aur-add reviews each
# PKGBUILD; in the logged (no-TTY) installer it builds the pre-vetted list
# non-interactively. See SECURITY.md.
mapfile -t aur_pkgs < <(grep -v '^#' "$ARCHY_INSTALL/archy-aur.packages" | grep -v '^$')

if [[ ${#aur_pkgs[@]} -gt 0 ]]; then
  archy-aur-notice
  # Keep sudo authenticated through the (potentially long) AUR builds so its
  # timestamp doesn't expire and re-prompt mid-build.
  source archy-sudo-keepalive
  archy-pkg-aur-add "${aur_pkgs[@]}"
fi
