# Apple/Mac keyboards: ensure Command = Super and Option = Alt.
# This is the hid_apple default (swap_opt_cmd=0); we pin it so the Super/Alt
# keybindings always fire from Cmd/Option. Harmless on non-Apple keyboards.
conf=/etc/modprobe.d/hid_apple.conf
want='options hid_apple swap_opt_cmd=0'
if [[ ! -f $conf ]] || ! grep -qxF "$want" "$conf"; then
  echo "$want" | sudo tee "$conf" >/dev/null
  sudo mkinitcpio -P
fi
