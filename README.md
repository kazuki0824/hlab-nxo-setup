# hlab-nxo-setup

## How to use

1. Clone this recursively ```git clone https://github.com/kazuki0824/hlab-nxo-setup.git --depth 1 --recursive```
2. Get some large contents by running ```cd hlab-nxo-setup && git lfs pull```
2. Enter externals/, and then run ```./install_RTP.sh```
3. Install ROS1 by following [this](INSTALL_ROS.md) instruction 
4. Enter overlay\_ws/, and run ```ROS_DISTRO=<your_distro> ./setup_rtmros_ws.sh```
5. ```bash ./opennextage_kazuki.sh```

## How to use (Docker)
