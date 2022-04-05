#!/bin/bash
set -eu

export GRASP_PLUGINS="Grasp;PRM;GeometryHandler;RobotInterface;ConstraintIK;SoftFingerStability;PCL;GraspDataGen;MotionFile"
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

ln -s `readlink -f ./grasp-plugin` ./choreonoid/ext/graspPlugin
echo "Ubuntu $VERSION_ID is selected. Installing dependencies...\n"


wget --spider https://raw.githubusercontent.com/choreonoid/choreonoid/v1.7.0/misc/script/install-requisites-ubuntu-$VERSION_ID.sh
if [ $? -eq 0 ]; then
  rm ./choreonoid/misc/script/install-requisites-ubuntu-$VERSION_ID.sh || :
  wget https://raw.githubusercontent.com/choreonoid/choreonoid/v1.7.0/misc/script/install-requisites-ubuntu-$VERSION_ID.sh -P ./choreonoid/misc/script/
else
  echo 'Fetching has been skipped since not found.\n'
fi
source ./choreonoid/misc/script/install-requisites-ubuntu-$VERSION_ID.sh


echo "Entering build-choreonoid/...\n"
mkdir ./build-choreonoid && cd ./build-choreonoid
cmake ../choreonoid -DGRASP_PLUGINS=$GRASP_PLUGINS \
-DGRASP_ROBOT_MODELS_PLUGINS=$GRASP_ROBOT_MODELS_PLUGINS \
-DBUILD_GRASP_PCL_PLUGIN=ON \
-DUSE_QT5=ON
LIBRARY_PATH=/opt/ros/${ROS_DISTRO}/lib make -j`nproc` -k && cd ..
echo "Leaving build-choreonoid/...\n"


echo "Regenerate IDL...\n"
ARRAY[0]="hlab-nxo-setup/externals/hironx-interface/HiroNXInterface/HiroNXGUI/HIROController.idl"
ARRAY[1]="hlab-nxo-setup/externals/hironx-interface/HiroNXInterface/HiroNXGUI/HiroNX.idl"
ARRAY[2]="choreonoid/ext/graspPlugin/RobotInterface/Nextage/NextageInterface/HIROController.idl"
ARRAY[3]="choreonoid/ext/graspPlugin/RobotInterface/Nextage/NextageInterface/HiroNX.idl"
ARRAY[4]="choreonoid/ext/graspPlugin/RobotInterface/Nextage/PortDuplicator/HIROController.idl"
ARRAY[5]="choreonoid/ext/graspPlugin/RobotInterface/Nextage/PortDuplicator/HiroNX.idl"
ARRAY[6]="choreonoid/ext/graspPlugin/RobotInterface/Nextage/THK/HIROController.idl"
ARRAY[7]="choreonoid/ext/graspPlugin/RobotInterface/Nextage/THK/HiroNX.idl"

for item in ${ARRAY[@]}
do
  P=`pwd`
  NAME=`basename $item`
  echo "Entering `dirname $item`..."
  cd $(readlink -f `dirname $item`)
  omniidl -bpython -v $NAME
  cd $P
done

