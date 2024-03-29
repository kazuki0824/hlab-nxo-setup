#!/bin/bash
set -u

export DEBIAN_FRONTEND=noninteractive

# Compatibility
export GRASP_PLUGINS="Grasp;PRM;GeometryHandler;ConstraintIK;SoftFingerStability;PCL;GraspDataGen;MotionFile"
export GRASP_ROBOT_MODEL_PLUGINS='HIRO/Plugin'
export CNOID_TAG=${1:-master}

export USE_PYTHON3="ON"
export ENABLE_BACKWARD_COMPATIBILITY="ON"

env | grep ROS_DISTRO
env | grep CNOID
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

git clone https://github.com/choreonoid/choreonoid.git
cd choreonoid
git checkout -d "$CNOID_TAG"
cd ..

ln -s "$(readlink -f ./grasp-plugin)" ./choreonoid/ext/graspPlugin
echo "Ubuntu $VERSION_ID is selected. Installing dependencies..."


wget --spider https://raw.githubusercontent.com/choreonoid/choreonoid/master/misc/script/install-requisites-ubuntu-"$VERSION_ID".sh
if [ $? -eq 0 ]; then
  rm ./choreonoid/misc/script/install-requisites-ubuntu-"$VERSION_ID".sh || :
  wget https://raw.githubusercontent.com/choreonoid/choreonoid/master/misc/script/install-requisites-ubuntu-"$VERSION_ID".sh -P ./choreonoid/misc/script/
else
  echo 'Fetching has been skipped since not found.'
fi
sleep 2
source ./choreonoid/misc/script/install-requisites-ubuntu-"$VERSION_ID".sh

# Compatibility
sudo apt install libboost-all-dev libpcl-dev liblapack-dev freeglut3-dev libusb-1.0-0-dev --no-install-recommends -y

## See: https://docs.python.org/ja/3/c-api/unicode.html
## バージョン 3.7 で変更: 返り値の型が char * ではなく const char * になりました。
echo "Patching the following file(s):"
find ./choreonoid/src -name 'PyQString.h'
find ./choreonoid/src -name 'PyQString.h' | xargs sed -i 's/  char\* data = PyUnicode_AsUTF8AndSize/  const char\* data = PyUnicode_AsUTF8AndSize/g'
find ./choreonoid/src -name 'PyQtCore.cpp'
find ./choreonoid/src -name 'PyQtCore.cpp' | xargs sed -i 's/.def("startTimer", \&QObject::startTimer)/.def("startTimer", (int (QObject::*)(int, Qt::TimerType)) \&QObject::startTimer)/g'
find ./choreonoid/src -name 'PyQtCore.cpp' | xargs sed -i 's/.def("setInterval", \&QTimer::setInterval)/.def("setInterval", (void (QTimer::*)(int)) \&QTimer::setInterval)/g'
sleep 2


echo "Entering build-choreonoid/..."
mkdir ./build-choreonoid && cd ./build-choreonoid

set -e
cmake ../choreonoid -DGRASP_PLUGINS=$GRASP_PLUGINS \
-DGRASP_ROBOT_MODEL_PLUGINS=$GRASP_ROBOT_MODEL_PLUGINS \
-DBUILD_GRASP_PCL_PLUGIN=ON \
-DREAD_PCD_ON=ON \
-DUSE_PYTHON3=$USE_PYTHON3 \
-DBUILD_POSE_SEQ_PLUGIN=ON \
-DENABLE_BACKWARD_COMPATIBILITY=$ENABLE_BACKWARD_COMPATIBILITY
make -k -j$(nproc)
cd ..
echo "Leaving build-choreonoid/..."


