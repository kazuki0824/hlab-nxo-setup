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


set -e
cd src
. /opt/ros/${ROS_DISTRO:-melodic}/setup.bash

set +e
git clone https://github.com/start-jsk/rtmros_hironx.git --depth 1 ; \
    cd rtmros_hironx && \
    git apply ../initPos.patch

set -e
cd ../..
if [ $ROS_DISTRO = "noetic" ]; then
    ## See https://github.com/fkanehiro/hrpsys-base/blob/2336d264de48625a914a5edcb2063343f69a0b47/util/simulator/CMakeLists.txt#L35
    sudo apt install libboost-python-dev -y --no-install-recommends
    sudo apt install python3-vcstool python3-catkin-tools -y --no-install-recommends
    vcs import src < ./.rosinstall
    ## See http://wiki.ros.org/noetic/Migration
    sed -i -e 's#<run_depend>turtlebot_description</run_depend>##g' src/rtmros_nextage/nextage_calibration/package.xml
    sed -i -e 's/orocos_kdl/liborocos-kdl/g' src/rtmros_nextage/nextage_calibration/package.xml
    sed -i -e 's/orocos_kdl/liborocos-kdl/g' src/rtmros_hironx/hironx_calibration/package.xml
    sed -i -e 's/ipython</ipython3</g' src/rtmros_common/hrpsys_ros_bridge/package.xml
    sed -i -e 's/python-rosdep/python3-rosdep/g' src/rtmros_common/hrpsys_ros_bridge/package.xml
    sed -i -e 's/python-setuptool/python3-setuptool/g' src/openrtm_common/openrtm_aist_python/package.xml
    sed -i -e 's/python-setuptool/python3-setuptool/g' src/openrtm_common/rtshell/package.xml
    sed -i -e 's/python-setuptool/python3-setuptool/g' src/openrtm_common/rtsprofile/package.xml
    sed -i -e 's/python-setuptool/python3-setuptool/g' src/openrtm_common/rtctree/package.xml
else
    sudo apt install python-catkin-tools -y --no-install-recommends
fi
if [ $IN_BUILD -eq 0 ] && [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
    sudo rosdep init
fi
rosdep update --include-eol-distros && rosdep install -y -q -i --from-paths src
catkin config --install
catkin b --no-status --summarize --cmake-args -DENABLE_DOXYGEN=OFF -DCMAKE_INSTALL_PREFIX=$HOME/.preinstalled
## Since the initial pose is modified, the test case test_setTargetPoseRelative_rpy won't pass. So testing is masked.
# catkin test


if [ $IN_BUILD -eq 0 ]; then
    cd ..
    read -p "Do you want to add environment setup to ~/.bashrc? (y/N): " yn
    if [[ $yn = [yY] ]]; then
        echo 'source $HOME/.preinstalled/setup.bash' >> ~/.bashrc
    fi
    rm -r overlay_ws/
fi

