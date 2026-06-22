# Set identification from install inputs
if [[ -n ${ARCHY_USER_NAME//[[:space:]]/} ]]; then
  git config --global user.name "$ARCHY_USER_NAME"
fi

if [[ -n ${ARCHY_USER_EMAIL//[[:space:]]/} ]]; then
  git config --global user.email "$ARCHY_USER_EMAIL"
fi
