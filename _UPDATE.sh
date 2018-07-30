#!/usr/bin/env bash

# run this after initial installation

# Exit script as soon as a command fails.
set -o errexit

# FUNCS
check_continue() {
  read -p '[y]es to continue: ' do_continue
  if [ "$do_continue" != "y" ]; then
    echo "Input was not 'y' - exiting"
    exit 1
  fi
}

# MAIN
echo "_UPDATE.sh - continue?"
check_continue

if [ -f "CONTRIBUTING.md" ] || [ -f "ethpm.json" ]; then
  echo "CONTRIBUTING.md or ethpm.json exists! Did you ever run ./_INSTALL.sh?"
  check_continue
fi

npm install
npm update
npm prune
git add . && git commit -m "npm update && npm prune"

#npm run test

echo # newline
echo "_UPDATE.sh complete!"
exit 0
