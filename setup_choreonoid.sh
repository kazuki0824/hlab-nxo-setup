#!/bin/bash
set -eu

export GRASP_PLUGINS="Grasp\;PRM\;GeometryHandler\;RobotInterface\;ConstraintIK\;SoftFingerStability\;PCL\;GraspDataGen\;MotionFile"
export GRASP_ROBOT_MODELS_PLUGINS='HIRO/Plugin'
export CNOID_TAG=${1:-v1.7.0}
env | grep ROS_DISTRO
env | grep CNOID_TAG
env | grep GRASP
. /etc/os-release
echo "Ubuntu $VERSION_ID is selected."
sleep 3



if [ ! -d ./hlab-nxo-setup ]; then
  echo "./hlab-nxo-setup not found.\n"
  exit 1
fi
if [ ! -d ./grasp-plugin ]; then
  echo "./grasp-plugin not found. Please clone it first.\n"
  exit 1
fi

git clone https://github.com/choreonoid/choreonoid.git --depth 1 -b $CNOID_TAG

ln -s `realpath ./grasp-plugin` ./choreonoid/ext/graspPlugin
echo "Ubuntu $VERSION_ID is selected. Installing dependencies..."
if [! -f ./choreonoid/misc/script/install-requisites-ubuntu-$VERSION_ID.sh ]; then
    wget https://raw.githubusercontent.com/choreonoid/choreonoid/master/misc/script/install-requisites-ubuntu-$VERSION_ID.sh -P ./choreonoid/misc/script/
fi
source ./choreonoid/misc/script/install-requisites-ubuntu-$VERSION_ID.sh


echo "Entering build-choreonoid/..."
mkdir ./build-choreonoid && cd ./build-choreonoid
cmake ../choreonoid -DGRASP_PLUGINS=$GRASP_PLUGINS \
-DGRASP_ROBOT_MODELS_PLUGINS=$GRASP_ROBOT_MODELS_PLUGINS \
-DBUILD_GRASP_PCL_PLUGIN=ON
LIBRARY_PATH=/opt/ros/${ROS_DISTRO}/lib make -j`nproc` -k && cd ..
echo "Leaving build-choreonoid/..."
