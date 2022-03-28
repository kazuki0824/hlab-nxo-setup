#!/bin/bash
set -e

cd src
git clone https://github.com/start-jsk/rtmros_hironx.git --depth 1 && \
    cd rtmros_hironx && \
    git apply ../initPos.patch
    
cd ../..

. /opt/ros/${ROS_DISTRO:-melodic}/setup.bash
rosdep update && rosdep install -y -i --from-paths src
catkin config --install
catkin b


if [ -f /.dockerenv ]; then
    cp -r ./install /opt/preinstalled
else
    sudo cp -r ./install /opt/preinstalled
    cd .. && rm -r overlay_ws/
fi

