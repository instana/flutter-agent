#!/usr/bin/env bash

REPO_DIR=`pwd`

apt-get install -y wget tar xz-utils git maven
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.7-stable.tar.xz
tar -xvf flutter_linux_3.16.7-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
git config --global --add safe.directory `pwd`/flutter
flutter --version

cd $REPO_DIR
if [ -f "coverage/lcov.info" ]; then
    rm -rf coverage
fi

flutter test --coverage