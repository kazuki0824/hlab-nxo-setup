#!/bin/bash

#https://stackoverflow.com/questions/69860182/how-to-detect-if-the-current-script-is-running-in-a-docker-build
isDocker(){
    local cgroup=/proc/1/cgroup
    test -f $cgroup && [[ "$(<$cgroup)" = *:cpuset:/docker/* ]]
}

isDockerBuildkit(){
    local cgroup=/proc/1/cgroup
    test -f $cgroup && [[ "$(<$cgroup)" = *:cpuset:/docker/buildkit/* ]]
}

isDockerContainer(){
    [ -e /.dockerenv ]
}

if isDockerBuildkit || (isDocker && ! isDockerContainer) then
  IN_BUILD=1
else
  IN_BUILD=0
fi


set -eu
if [ ! -f eclipse-java-oxygen-3a-linux-gtk-x86_64.tar.gz ]; then
    curl -OJL https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/oxygen/3a/eclipse-java-oxygen-3a-linux-gtk-x86_64.tar.gz
fi
tar zxvf eclipse-java-oxygen-3a-linux-gtk-x86_64.tar.gz

PKGS='openjdk-8-jdk ant'
if [ $IN_BUILD -eq 0 ]; then
    sudo apt install software-properties-common -y
    sudo add-apt-repository ppa:openjdk-r/ppa -y
    sudo apt install -y --no-install-recommends $PKGS
fi

cd OpenRTP-aist
export ECLIPSE_HOME=$PWD/../eclipse
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
./build_all

sed -i -e "s#file:///home/openrtm/public_html/pub/eclipse/projects/oxygen,##" ./install_plugins
./install_plugins $ECLIPSE_HOME

unzip -j -d ../eclipse/dropins openrtp-*.zip

if [ $IN_BUILD -ne 0 ]; then
  cd .. && rm -r OpenRTP-aist
else
  cd ..
  sudo apt purge $PKGS --auto-remove -y
  sudo apt install openjdk-8-jre -y --no-install-recommends
  sudo update-java-alternatives -s java-1.8.0-openjdk-amd64
  sudo rm -r OpenRTP-aist
fi

