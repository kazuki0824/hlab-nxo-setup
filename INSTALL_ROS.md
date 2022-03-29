## This document
roughly follows [this](http://wiki.ros.org/melodic/Installation/Ubuntu).

## Run
```bash
sudo apt install -y --no-install-recommends curl lsb-release git
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt update
sudo apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential # 時代が進んだら、Python3のものに変更してください
sudo apt install -y ros-melodic-desktop-full python-catkin-tools
```
