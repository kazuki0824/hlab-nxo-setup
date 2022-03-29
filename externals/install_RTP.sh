#!/bin/bash
set -eu
tar zxvf eclipse-jee-oxygen-3a-linux-gtk-x86_64.tar.gz

PKGS='openjdk-8-jdk ant'
sudo apt install -y --no-install-recommends $PKGS

cd OpenRTP-aist
export ECLIPSE_HOME=$PWD/../eclipse
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
./build_all

sed -i -e "s#file:///home/openrtm/public_html/pub/eclipse/projects/oxygen,##" ./install_plugins
./install_plugins $ECLIPSE_HOME

unzip -j -d ../eclipse/dropins openrtp-*.zip

cd .. && rm -r OpenRTP-aist

sudo apt purge $PKGS --auto-remove
sudo apt install openjdk-8-jre -y --no-install-recommends
