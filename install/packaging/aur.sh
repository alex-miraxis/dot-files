# Install AUR packages. The logged installer is unattended (run_logged feeds
# /dev/null to stdin), so build the pre-vetted list non-interactively. Running
# `archy-pkg-aur-add <pkg>` by hand in a terminal still reviews each PKGBUILD.
mapfile -t aur_pkgs < <(grep -v '^#' "$ARCHY_INSTALL/archy-aur.packages" | grep -v '^$')

if [[ ${#aur_pkgs[@]} -gt 0 ]]; then
  archy-aur-notice
  # Keep sudo authenticated through the (long) AUR builds.
  source archy-sudo-keepalive
  ARCHY_AUR_TRUST=1 archy-pkg-aur-add "${aur_pkgs[@]}"
fi
