#!/usr/bin/env bash

REPO_DIR=`pwd`

yum update -y
yum install -y wget tar xz xz-devel git maven java-21-openjdk-devel
export JAVA_HOME=/usr/lib/jvm/jre-21-openjdk

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