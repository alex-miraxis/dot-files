# MacBook T2 audio firmware mirror (only added on genuine Apple T2 hardware)
if lspci -nn 2>/dev/null | grep -q "106b:180[12]"; then
  if ! grep -q '^\[arch-mact2\]' /etc/pacman.conf; then
    cat <<EOF | sudo tee -a /etc/pacman.conf >/dev/null

[arch-mact2]
Server = https://github.com/NoaHimesaka1873/arch-mact2-mirror/releases/download/release
SigLevel = Never
EOF
  fi
fi
