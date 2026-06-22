# Provision language runtimes with mise: Node, Python, Go, Rust.
# Recorded globally in ~/.config/mise/config.toml and activated by the shell.
# Use precompiled Python to avoid a slow source build during install.
export MISE_PYTHON_COMPILE=0
if command -v mise &>/dev/null; then
  mise use --global --yes node@lts python@latest go@latest rust@latest ||
    echo "Note: some runtimes didn't install; run 'mise use --global node python go rust' later."
fi

# OpenAI Codex CLI — the native Codex on Linux (the Codex desktop app is
# macOS/Windows only as of 2026). Installed into mise's Node toolchain.
if command -v mise &>/dev/null; then
  mise exec node@lts -- npm install -g @openai/codex ||
    echo "Note: Codex CLI not installed; run 'npm install -g @openai/codex' later."
fi
