#!/bin/bash
set -e

. /opt/preinstalled/setup.bash


gnome-terminal --window -e "bash -c \"sleep 3; ./eclipse/eclipse -debug -console; exec bash\"" \
--tab -e "bash -c \"source $ROS_OVERLAY_CMD ; ./choreonoid-1.7.0/ext/graspPlugin/RobotInterface/Nextage/THK/HandManipProvider.py; exec bash\"" \
--tab -e "bash -c \"source $ROS_OVERLAY_CMD ; ./choreonoid-1.7.0/ext/graspPlugin/RobotInterface/Nextage/PortDuplicator/PortDuplicator.py; exec bash\"" \
--tab -e "bash -c \"source $ROS_OVERLAY_CMD ; cd ./choreonoid-1.7.0/ext/graspPlugin/RobotInterface/Nextage/NextageInterface; ./HiroNXProvider.py;exec bash\"" \
--tab -e "bash -c \"source $ROS_OVERLAY_CMD ; externals/hironx-interface/HiroNXInterface/HiroNXGUI/WxHiroNXGUI.py; exec bash\"" 

