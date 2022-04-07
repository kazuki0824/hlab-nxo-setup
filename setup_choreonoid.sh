#!/bin/bash
set -eu

# Compatibility
export GRASP_PLUGINS="Grasp;PRM;GeometryHandler;RobotInterface;ConstraintIK;SoftFingerStability;PCL;GraspDataGen;MotionFile"
export GRASP_ROBOT_MODEL_PLUGINS='HIRO/Plugin'
export CNOID_TAG=${1:-v1.7.0}
if [ $CNOID_TAG = "v1.7.0" ]; then
  export USE_QT5="ON"
  export USE_PYTHON3="ON"
  export USE_PYBIND11="ON"
elif [   ${ROS_DISTRO} = "indigo"  ]; then
  export USE_QT5="OFF"
  export USE_PYTHON3="OFF"
  export USE_PYBIND11="OFF"
else
  export USE_QT5="ON"
  export USE_PYTHON3="OFF"
  export USE_PYBIND11="OFF"
fi
env | grep ROS_DISTRO
env | grep CNOID_TAG
env | grep GRASP
env | grep USE


. /etc/os-release
echo "Ubuntu $VERSION_ID is selected."
sleep 3

if [ ! -d ./hlab-nxo-setup ]; then
  echo "./hlab-nxo-setup not found."
  exit 1
fi
if [ ! -d ./grasp-plugin ]; then
  echo "./grasp-plugin not found. Please clone it first."
  exit 1
fi

git clone https://github.com/choreonoid/choreonoid.git --depth 1 -b $CNOID_TAG

ln -s `readlink -f ./grasp-plugin` ./choreonoid/ext/graspPlugin
echo "Ubuntu $VERSION_ID is selected. Installing dependencies..."


wget --spider https://raw.githubusercontent.com/choreonoid/choreonoid/v1.7.0/misc/script/install-requisites-ubuntu-$VERSION_ID.sh
if [ $? -eq 0 ]; then
  rm ./choreonoid/misc/script/install-requisites-ubuntu-$VERSION_ID.sh || :
  wget https://raw.githubusercontent.com/choreonoid/choreonoid/v1.7.0/misc/script/install-requisites-ubuntu-$VERSION_ID.sh -P ./choreonoid/misc/script/
else
  echo 'Fetching has been skipped since not found.'
fi
source ./choreonoid/misc/script/install-requisites-ubuntu-$VERSION_ID.sh

# Compatibility
if [  ${ROS_DISTRO} = "indigo" ]; then
  sudo apt install cmake3 -y
elif [ $CNOID_TAG = "v1.7.0" ]; then
  :
else
  sed -i -e 's/.def("startTimer", &QObject::startTimer)/.def("startTimer", (int (QObject::*)(int, Qt::TimerType)) &QObject::startTimer)/g' ./choreonoid/src/Base/boostpython/PyQtCore.cpp
  sed -i -e 's/.def("setInterval", &QTimer::setInterval)/.def("setInterval", (void (QTimer::*)(int)) &QTimer::setInterval)/g' ./choreonoid/src/Base/boostpython/PyQtCore.cpp
  sed -i -e 's/.def("startTimer", &QObject::startTimer)/.def("startTimer", (int (QObject::*)(int, Qt::TimerType)) &QObject::startTimer)/g' ./choreonoid/src/Base/pybind11/PyQtCore.cpp
  sed -i -e 's/.def("setInterval", &QTimer::setInterval)/.def("setInterval", (void (QTimer::*)(int)) &QTimer::setInterval)/g' ./choreonoid/src/Base/pybind11/PyQtCore.cpp
fi

echo "Entering build-choreonoid/..."
mkdir ./build-choreonoid && cd ./build-choreonoid
cmake ../choreonoid -DGRASP_PLUGINS=$GRASP_PLUGINS \
-DGRASP_ROBOT_MODEL_PLUGINS=$GRASP_ROBOT_MODEL_PLUGINS \
-DBUILD_GRASP_PCL_PLUGIN=ON \
-DUSE_QT5=$USE_QT5 \
-DUSE_PYTHON3=$USE_PYTHON3 \
-DUSE_PYBIND11=$USE_PYBIND11
LIBRARY_PATH=/opt/ros/${ROS_DISTRO}/lib make -j`nproc` -k && cd ..
echo "Leaving build-choreonoid/..."


echo "Regenerate IDL..."
ARRAY[0]="choreonoid/ext/graspPlugin/RobotInterface/Nextage/NextageInterface/HIROController.idl"
ARRAY[1]="choreonoid/ext/graspPlugin/RobotInterface/Nextage/NextageInterface/HiroNX.idl"
ARRAY[2]="choreonoid/ext/graspPlugin/RobotInterface/Nextage/PortDuplicator/HIROController.idl"
ARRAY[3]="choreonoid/ext/graspPlugin/RobotInterface/Nextage/PortDuplicator/HiroNX.idl"
ARRAY[4]="choreonoid/ext/graspPlugin/RobotInterface/Nextage/THK/HIROController.idl"
ARRAY[5]="choreonoid/ext/graspPlugin/RobotInterface/Nextage/THK/HiroNX.idl"

#ARRAY[6]="hlab-nxo-setup/externals/hironx-interface/HiroNXInterface/HiroNXGUI/HIROController.idl"
#ARRAY[7]="hlab-nxo-setup/externals/hironx-interface/HiroNXInterface/HiroNXGUI/HiroNX.idl"

for item in ${ARRAY[@]}
do
  P=`pwd`
  NAME=`basename $item`
  echo "Entering `dirname $item`..."
  cd $(readlink -f `dirname $item`)
  omniidl -bpython -v $NAME
  cd $P
done

