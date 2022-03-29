#!/bin/bash
set -e

cd src
. /opt/ros/${ROS_DISTRO:-melodic}/setup.bash

git clone https://github.com/start-jsk/rtmros_hironx.git --depth 1 && \
    cd rtmros_hironx && \
    git apply ../initPos.patch
    
cd ../..

rosdep update && rosdep install -y -i --from-paths src
catkin config --install
catkin b


if [ -f /.dockerenv ]; then
    cp -r ./install /opt/preinstalled
else
    sudo cp -r ./install /opt/preinstalled
    cd .. && rm -r overlay_ws/
    read -n1 -p "Do you want to add environment setup to ~/.bashrc? (y/N): " yn
    if [[ $yn = [yY] ]]; then
        realpath ./rtm_entrypoint.sh >> ~/.bashrc
    fi
fi

