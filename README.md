# hlab-nxo-setup
[![Docker](https://github.com/kazuki0824/hlab-nxo-setup/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/kazuki0824/hlab-nxo-setup/actions/workflows/docker-publish.yml)
[![Check OpenRTP Installer](https://github.com/kazuki0824/hlab-nxo-setup/actions/workflows/openrtp_deployment_test.yml/badge.svg)](https://github.com/kazuki0824/hlab-nxo-setup/actions/workflows/openrtp_deployment_test.yml)
[![graspPlugin Builder](https://github.com/kazuki0824/hlab-nxo-setup/actions/workflows/graspPlugin_integrity.yml/badge.svg)](https://github.com/kazuki0824/hlab-nxo-setup/actions/workflows/graspPlugin_integrity.yml)

## 対応状況
[![graspPlugin Builder](https://github.com/kazuki0824/hlab-nxo-setup/actions/workflows/graspPlugin_integrity.yml/badge.svg)](https://github.com/kazuki0824/hlab-nxo-setup/actions/workflows/graspPlugin_integrity.yml)
⇐これが*緑色*になっているとき、以下の環境でテスト済み。

### 単体
```
GRASP_PLUGINS="Grasp;PRM;GeometryHandler;ConstraintIK;SoftFingerStability;PCL;GraspDataGen;MotionFile"
GRASP_ROBOT_MODEL_PLUGINS='HIRO/Plugin'
```
Ubuntu 20.04とmasterブランチのChoreonoidとの組み合わせでビルド可

### graspPlugin + RobotInterface + rtmros_nextage
|          | noetic    | melodic | kinetic | indigo |
|---|---|---|---|---|
| Choreonoid v1.7.0  | ※ | ✅ | ✅ | ✅ |
| Choreonoid v1.6.0  | ※ | ✅ | ✅ | ✅ |
| Choreonoid v1.5.0  | ※ | ✅ | ✅ | ✅ |

※ビルド可, rtshell非対応

## How to use
### Nextage, ROS, OpenRTP
1. Clone this recursively ```git clone https://github.com/kazuki0824/hlab-nxo-setup.git --depth 1 --recursive```
   <!--Get some large contents by running ```cd hlab-nxo-setup && git lfs pull```-->
2. Enter externals/, and then run ```sudo apt install curl -y &&./install_RTP.sh```
3. Install ROS1 by following [this](INSTALL_ROS.md) instruction 
4. Enter overlay\_ws/, and run ```ROS_DISTRO=<your_distro> ./setup_rtmros_ws.sh```
5. ```source $HOME/.preinstalled/setup.bash```

### Build choreonoid, graspPlugin
1. Move the current directory to the location where hlab-nxo-setup is located. (i.e., out of 'hlab-nxo-setup')
2. Install wget from apt. ```sudo apt install wget```
3. Clone the graspPlugin repository in the same directory where hlab-nxo-setup is located. At this time, the name of the cloned directory should be 'grasp-plugin'.
4. Run ```hlab-nxo-setup/setup_choreonoid.sh <tag_name_of_cnoid>```. The tested <tag_name_of_cnoid> value sets are v1.7.0, v1.6.0, and v1.5.0.

### Get ready
After all the components above are installed, run the following.
1. 
```bash
sudo apt install cmake-qt-gui gnome-terminal dbus-x11 -y
```
2. 
```bash
function connect_rtc() {
    source `rospack find rtshell`/bash_completion
    #rtcwd /localhost
    host=/localhost:2809/${HOSTNAME}.host_cxt
    rtcon $host/HiroNXGUI0.rtc:HiroNX $host/PortDuplicator0.rtc:HiroNX
    rtcon $host/HiroNXGUI0.rtc:HIRO $host/PortDuplicator0.rtc:HIRO
    rtcon $host/ArmController0.rtc:HiroNX $host/PortDuplicator0.rtc:HiroNX
    rtcon $host/ArmController0.rtc:HIRO $host/PortDuplicator0.rtc:HIRO
    rtcon $host/PortDuplicator0.rtc:HiroNX0 $host/HiroNXProvider0.rtc:HiroNX
    rtcon $host/PortDuplicator0.rtc:HIRO0 $host/HiroNXProvider0.rtc:HIRO
    rtcon $host/PortDuplicator0.rtc:HiroNX1 $host/HandManipProvider0.rtc:HiroNX
    rtcon $host/PortDuplicator0.rtc:HIRO1 $host/HandManipProvider0.rtc:HIRO
    rtact $host/HiroNXGUI0.rtc $host/HiroNXProvider0.rtc $host/ArmController0.rtc $host/PortDuplicator0.rtc $host/HandManipProvider0.rtc
}
```
This is the bash function to connect all the RT components automatically.

3. 
```bash
rtm-naming
gnome-terminal --window -e "bash -c \"sleep 3; ./hlab-nxo-setup/externals/eclipse/eclipse -debug -console; exec bash\"" \
--tab -e "bash -c \" ./build-choreonoid/bin/choreonoid; exec bash\"" \
--tab -e "bash -c \" ./choreonoid/ext/graspPlugin/RobotInterface/Nextage/THK/HandManipProvider.py; exec bash\"" \
--tab -e "bash -c \" ./choreonoid/ext/graspPlugin/RobotInterface/Nextage/PortDuplicator/PortDuplicator.py; exec bash\"" \
--tab -e "bash -c \" cd ./choreonoid/ext/graspPlugin/RobotInterface/Nextage/NextageInterface; ./HiroNXProvider.py;exec bash\"" \
--tab -e "bash -c \" ./hlab-nxo-setup/externals/hironx-interface/HiroNXInterface/HiroNXGUI/WxHiroNXGUI.py; exec bash\"" 
connect_rtc
```

## How to use (Docker)
### Use a pre-built image
1. Run the following to establish the container
```bash
xhost +local:user && \
docker run --rm --gpus all -it -e DISPLAY=unix$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix ghcr.io/kazuki0824/hlab-nxo-setup:noetic && \
xhost -local:user
```
2. 
```bash
git clone http://spica.ms.t.kanazawa-u.ac.jp/gitlab/tsuji/grasp-plugin.git --depth 1  -b fix_compatibility_2004_2204 && \
hlab-nxo-setup/setup_choreonoid.sh
```

3. 
```bash
function connect_rtc() {
    source `rospack find rtshell`/bash_completion
    #rtcwd /localhost
    host=/localhost:2809/${HOSTNAME}.host_cxt
    rtcon $host/HiroNXGUI0.rtc:HiroNX $host/PortDuplicator0.rtc:HiroNX
    rtcon $host/HiroNXGUI0.rtc:HIRO $host/PortDuplicator0.rtc:HIRO
    rtcon $host/ArmController0.rtc:HiroNX $host/PortDuplicator0.rtc:HiroNX
    rtcon $host/ArmController0.rtc:HIRO $host/PortDuplicator0.rtc:HIRO
    rtcon $host/PortDuplicator0.rtc:HiroNX0 $host/HiroNXProvider0.rtc:HiroNX
    rtcon $host/PortDuplicator0.rtc:HIRO0 $host/HiroNXProvider0.rtc:HIRO
    rtcon $host/PortDuplicator0.rtc:HiroNX1 $host/HandManipProvider0.rtc:HiroNX
    rtcon $host/PortDuplicator0.rtc:HIRO1 $host/HandManipProvider0.rtc:HIRO
    rtact $host/HiroNXGUI0.rtc $host/HiroNXProvider0.rtc $host/ArmController0.rtc $host/PortDuplicator0.rtc $host/HandManipProvider0.rtc
}
```
4. 
```bash
rtm-naming
gnome-terminal --window -e "bash -c \"sleep 3; ./hlab-nxo-setup/externals/eclipse/eclipse -debug -console; exec bash\"" \
--tab -e "bash -c \" ./build-choreonoid/bin/choreonoid; exec bash\"" \
--tab -e "bash -c \" ./choreonoid/ext/graspPlugin/RobotInterface/Nextage/THK/HandManipProvider.py; exec bash\"" \
--tab -e "bash -c \" ./choreonoid/ext/graspPlugin/RobotInterface/Nextage/PortDuplicator/PortDuplicator.py; exec bash\"" \
--tab -e "bash -c \" cd ./choreonoid/ext/graspPlugin/RobotInterface/Nextage/NextageInterface; ./HiroNXProvider.py;exec bash\"" \
--tab -e "bash -c \" ./hlab-nxo-setup/externals/hironx-interface/HiroNXInterface/HiroNXGUI/WxHiroNXGUI.py; exec bash\"" 
connect_rtc
```

### Build the Image
1. 
```bash
cd hlab-nxo-setup
docker build . --build-arg DISTRIBUTION=<your_distro_name> -t grasp_img
```
#### First time
2. 
```bash
xhost +local:user && \
docker run --name grasp --gpus all -it -e DISPLAY=unix$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix grasp_img && \
xhost -local:user
```
3. Inside a container, run ```git clone http://spica.ms.t.kanazawa-u.ac.jp/gitlab/tsuji/grasp-plugin.git -b <branch>``` and enter your credential.
4. Modify setup_choreonoid.sh.
https://github.com/kazuki0824/hlab-nxo-setup/blob/de4e6b07d41c6105e34efb9b2fae419d0bb2ad41/setup_choreonoid.sh#L5-L6
5. 
```bash
hlab-nxo-setup/setup_choreonoid.sh <tag>
```
6. Exit the container.

To build Choreonoid manually, follow [this](https://gist.github.com/kazuki0824/68b4cc31a545bb71d6af11322545236b).

#### Later
```bash
docker start grasp && \
xhost +local:user && \
docker exec -it -e DISPLAY=unix$DISPLAY grasp /rtm_entrypoint.sh bash && \
xhost -local:user && \
docker stop grasp

```

And then run:
```bash
gnome-terminal --window -e "bash -c \"sleep 3; ./hlab-nxo-setup/externals/eclipse/eclipse -debug -console; exec bash\"" \
--tab -e "bash -c \" ./build-choreonoid/bin/choreonoid; exec bash\"" \
--tab -e "bash -c \" ./choreonoid/ext/graspPlugin/RobotInterface/Nextage/THK/HandManipProvider.py; exec bash\"" \
--tab -e "bash -c \" ./choreonoid/ext/graspPlugin/RobotInterface/Nextage/PortDuplicator/PortDuplicator.py; exec bash\"" \
--tab -e "bash -c \" cd ./choreonoid/ext/graspPlugin/RobotInterface/Nextage/NextageInterface; ./HiroNXProvider.py;exec bash\"" \
--tab -e "bash -c \" ./hlab-nxo-setup/externals/hironx-interface/HiroNXInterface/HiroNXGUI/WxHiroNXGUI.py; exec bash\"" 
connect_rtc

```

## Testing
To test the operation of HiroNXProvider/HiroNXGUI on a simulation instead of connecting to the actual device, perform the following steps.
This changes which machine the RobotInterface tries to connect to.
```bash
echo 'HiroNX(Robot)0' > ./choreonoid/ext/graspPlugin/RobotInterface/Nextage/NextageInterface/.robotname
echo localhost:15005 > ./choreonoid/ext/graspPlugin/RobotInterface/Nextage/NextageInterface/.robothost

```
After this, you can control the simulated robot in the hrpsys-simulator through HiroNXGUI and RobotInterface plugin.

