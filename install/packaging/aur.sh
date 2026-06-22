# Install AUR packages with mandatory PKGBUILD review.
# Set ARCHY_AUR_TRUST=1 to skip review for fully-unattended installs (less safe).
mapfile -t aur_pkgs < <(grep -v '^#' "$ARCHY_INSTALL/archy-aur.packages" | grep -v '^$')

if [[ ${#aur_pkgs[@]} -gt 0 ]]; then
  archy-aur-notice
  archy-pkg-aur-add "${aur_pkgs[@]}"
fi
