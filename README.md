# hlab-nxo-setup
[![Docker](https://github.com/kazuki0824/hlab-nxo-setup/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/kazuki0824/hlab-nxo-setup/actions/workflows/docker-publish.yml)
[![Check OpenRTP Installer](https://github.com/kazuki0824/hlab-nxo-setup/actions/workflows/openrtp_deployment_test.yml/badge.svg)](https://github.com/kazuki0824/hlab-nxo-setup/actions/workflows/openrtp_deployment_test.yml)
[![graspPlugin Builder](https://github.com/kazuki0824/hlab-nxo-setup/actions/workflows/graspPlugin_integrity.yml/badge.svg)](https://github.com/kazuki0824/hlab-nxo-setup/actions/workflows/graspPlugin_integrity.yml)

## How to use

1. Clone this recursively ```git clone https://github.com/kazuki0824/hlab-nxo-setup.git --depth 1 --recursive```
2. Get some large contents by running ```cd hlab-nxo-setup && git lfs pull```
2. Enter externals/, and then run ```./install_RTP.sh```
3. Install ROS1 by following [this](INSTALL_ROS.md) instruction 
4. Enter overlay\_ws/, and run ```ROS_DISTRO=<your_distro> ./setup_rtmros_ws.sh```
5. ```source /opt/preinstalled/setup.bash```

## How to use (Docker)

### Build
```bash
cd hlab-nxo-setup
docker build . --build-arg DISTRIBUTION=<your_distro_name>
```

### Usage
```bash
xhost +local:user
docker run -it -e DISPLAY=unix$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix ghcr.io/kazuki0824/hlab-nxo-setup:melodic
xhost -local:user
```
Next, follow [this](https://gist.github.com/kazuki0824/68b4cc31a545bb71d6af11322545236b) tutorial to use Nextage.
<script src="https://gist.github.com/kazuki0824/68b4cc31a545bb71d6af11322545236b.js"></script>
