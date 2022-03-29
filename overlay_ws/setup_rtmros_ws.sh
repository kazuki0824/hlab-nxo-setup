#!/bin/bash
set -e
cd src
. /opt/ros/${ROS_DISTRO:-melodic}/setup.bash

set +e
git clone https://github.com/start-jsk/rtmros_hironx.git --depth 1 ; \
    cd rtmros_hironx && \
    git apply ../initPos.patch

set -e
cd ../..
if [ ! -f /.dockerenv ] && [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
    sudo rosdep init
fi
rosdep update --include-eol-distros && rosdep install -y -i --from-paths src
catkin config --install
catkin b


if [ -f /.dockerenv ]; then
    cp -r ./install /opt/preinstalled
else
    sudo cp -r ./install /opt/preinstalled
    
    cd ..
    read -n1 -p "Do you want to add environment setup to ~/.bashrc? (y/N): " yn
    if [[ $yn = [yY] ]]; then
        realpath ./rtm_entrypoint.sh >> ~/.bashrc
    fi
    sudo rm -r overlay_ws/
fi

