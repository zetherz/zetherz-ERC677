#!/usr/bin/env bash

# fork/clone this repo with your own LICENSE/README.md files, then run this script

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

# VARS
GITHUB_USER_NAME_DEF="YOUR-GITHUB-USERNAME"
GITHUB_USER_NAME=""
GITHUB_USER_EMAIL_DEF="YOUR-GITHUB-EMAIL"
GITHUB_USER_EMAIL=""
PROJ_NAME="YOUR-PROJ-NAME"
PROJ_DESC="YOUR PROJ DESC"
PROJ_KEYWORDS="'YOUR','PROJ','KEYWORDS'"
PROJ_HOMEPAGE_DEF="https://github.com/$GITHUB_USER_NAME_DEF/$PROJ_NAME"
PROJ_HOMEPAGE=""
PROJ_REPO_URL_DEF="$PROJ_HOMEPAGE_DEF.git"
PROJ_REPO_URL=""
PROJ_BUGS_URL_DEF="$PROJ_HOMEPAGE_DEF/issues"
PROJ_BUGS_URL=""

# MAIN
while getopts ":u:v:n:d:k:h:r:b:" opt; do
  case $opt in
    u)
      GITHUB_USER_NAME="$OPTARG"
      if [ "$PROJ_HOMEPAGE" == "" ]; then
        PROJ_HOMEPAGE="https://github.com/$GITHUB_USER_NAME/$PROJ_NAME"
        if [ "$PROJ_REPO_URL" == "" ]; then
          PROJ_REPO_URL="$PROJ_HOMEPAGE.git"
        fi
        if [ "$PROJ_BUGS_URL" == "" ]; then
          PROJ_BUGS_URL="$PROJ_HOMEPAGE/issues"
        fi
      fi
      ;;
    v)
      GITHUB_USER_EMAIL="$OPTARG"
      ;;
    n)
      PROJ_NAME="$OPTARG"
      ;;
    d)
      PROJ_DESC="$OPTARG"
      ;;
    k)
      PROJ_KEYWORDS="$OPTARG"
      ;;
    h)
      PROJ_HOMEPAGE="$OPTARG"
      ;;
    r)
      PROJ_REPO_URL="$OPTARG"
      ;;
    b)
      PROJ_BUGS_URL="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done

set +o errexit
git remote show ozs > /dev/null
if [ "$?" == 0 ]; then
  echo "git remote 'ozs' exists, so you must have already run this script. Run ./_UPDATE.sh instead!"
  exit 1
fi
set -o errexit

echo "git remote 'ozs' doesn't exist yet - configure now?"
check_continue

if [ "$GITHUB_USER_NAME" != "" ]; then
  git config user.name "$GITHUB_USER_NAME"
fi
if [ "$GITHUB_USER_EMAIL" != "" ]; then
  git config user.email "$GITHUB_USER_EMAIL"
fi
git remote add ozs https://github.com/OpenZeppelin/openzeppelin-solidity.git

#git fetch ozs
#git pull --rebase --allow-unrelated-histories -Xtheirs ozs master
git pull --no-edit --allow-unrelated-histories -Xours ozs master
#git diff --name-only --diff-filter=U | xargs git checkout HEAD # Unmerged, i.e. merge errored due to prior existence/previous deletion
#git diff --name-only --diff-filter=M | xargs git add # Modified, i.e. merged
#git commit -m "openzeppelin-solidity merge" --author="OpenZeppelin <contact@openzeppelin.org>"
if [ "$?" != 0 ]; then
  echo "git operation exited with error - exiting"
  exit 1
fi

rm -rf CONTRIBUTING.md ethpm.json CODE_OF_CONDUCT.md .github/ audit/ contracts/* test/*/ test/*.test.js
touch contracts/.gitkeep
touch test/.gitkeep

git add . && git commit -m "In the beginning..." # commit any initial files, i.e. this one

# update!
./_UPDATE.sh
if [ "$?" != 0 ]; then
  echo "_UPDATE.sh exited with error - exiting"
  exit 1
fi

if [ "$GITHUB_USER_NAME" == "" ]; then
  GITHUB_USER_NAME="$GITHUB_USER_NAME_DEF"
fi
if [ "$GITHUB_USER_EMAIL" == "" ]; then
  GITHUB_USER_EMAIL="$GITHUB_USER_EMAIL_DEF"
fi
if [ "$PROJ_HOMEPAGE" == "" ]; then
  PROJ_HOMEPAGE="$PROJ_HOMEPAGE_DEF"
fi
if [ "$PROJ_REPO_URL" == "" ]; then
  PROJ_REPO_URL="$PROJ_REPO_URL_DEF"
fi
if [ "$PROJ_BUGS_URL" == "" ]; then
  PROJ_BUGS_URL="$PROJ_BUGS_URL_DEF"
fi
npm install -g json
json -I -f package.json -e "this.name='$PROJ_NAME'"
json -I -f package.json -e "this.version='1.0.0'"
json -I -f package.json -e "this.description='$PROJ_DESC'"
json -I -f package.json -e "this.keywords.unshift($PROJ_KEYWORDS)"
json -I -f package.json -e "this.author='$GITHUB_USER_NAME <$GITHUB_USER_EMAIL>'"
json -I -f package.json -e "this.homepage='$PROJ_HOMEPAGE'"
json -I -f package.json -e "this.repository.url='$PROJ_REPO_URL'"
json -I -f package.json -e "this.bugs.url='$PROJ_BUGS_URL'"

npm install openzeppelin-solidity --save-dev # must run this after changing package.json => name (done above)

git add . && git commit -m "initial config"

git checkout --orphan master-new
git add -A
git commit -am "Initial commit"
git branch -D master # delete old master branch
git branch -m master # rename this to master

echo # newline
echo "_INSTALL.sh complete!"
exit 0
