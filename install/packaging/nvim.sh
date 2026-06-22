# Install the LazyVim-based Neovim config (theme follows the system theme)
# Don't clobber an existing user config.
if [ ! -e ~/.config/nvim ]; then
  mkdir -p ~/.config
  cp -R ~/.local/share/archy/config/nvim ~/.config/nvim
fi
