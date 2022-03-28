#!/bin/bash
set -eu
PKGS='openjdk-8-jdk ant'
sudo apt install -y --no-install-recommends $PKGS

tar zxvf eclipse-jee-oxygen-3a-linux-gtk-x86_64.tar.gz

cd OpenRTP-aist
export ECLIPSE_HOME=$PWD/../eclipse
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
./build_all

sed -i -e "s#file:///home/openrtm/public_html/pub/eclipse/projects/oxygen,##" ./install_plugins
./install_plugins $ECLIPSE_HOME

unzip -j -d ../eclipse/dropins openrtp-1.2.2.*.zip

#sudo apt purge $PKGS --auto-remove
