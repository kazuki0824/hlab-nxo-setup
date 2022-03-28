#!/bin/bash
set -eu

tar zxvf eclipse-jee-oxygen-3a-linux-gtk-x86_64.tar.gz

cd OpenRTP-aist
ECLIPSE_HOME=$PWD/../eclipse
./build_all

sed -i -e "s#file:///home/openrtm/public_html/pub/eclipse/projects/oxygen,##" ./install_plugins
./install_plugins $ECLIPSE_HOME

unzip -j -d ../eclipse/dropins openrtp-1.2.2.*.zip
