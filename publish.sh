#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# publish.sh - create the public GitHub repository and push the initial commit.
#
# Requires the GitHub CLI (https://cli.github.com):  gh auth login
# If you don't use gh, follow the printed manual instructions instead.
# ----------------------------------------------------------------------------
set -euo pipefail

REPO_NAME="OneFiveTen"
DESCRIPTION="Tiny 1/5/10 quick-stack buttons for Auctionator's selling tab (TBC Classic / Anniversary)"

if command -v gh >/dev/null 2>&1; then
  gh repo create "$REPO_NAME" --public --source . --remote origin --push \
    --description "$DESCRIPTION"
  echo
  echo "Done! Repo: https://github.com/$(gh api user -q .login)/$REPO_NAME"
else
  echo "GitHub CLI not found."
  echo
  echo "1) Create an empty PUBLIC repo named '$REPO_NAME' at:"
  echo "     https://github.com/new"
  echo
  echo "2) Then run:"
  echo "     git remote add origin git@github.com:YOUR_USERNAME/$REPO_NAME.git"
  echo "     git push -u origin main"
fi
