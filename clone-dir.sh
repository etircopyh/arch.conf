#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
IFS=$'\n\t'

neovimclonedir=/tmp/neovim-config

mkdir $neovimclonedir && cd $neovimclonedir

git init

git remote add -f origin https://github.com/etircopyh/arch.conf

git config core.sparseCheckout true

echo "$2" >> ./.git/info/sparse-checkout

git pull origin "$1"
