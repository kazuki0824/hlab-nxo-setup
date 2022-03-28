#!/bin/bash

function connect_rtc() {
    source `rospack find openrtm_tools`/scripts/rtshell-setup.sh
    rtcwd /localhost
    rtcon $host/HiroNXGUI0.rtc:HiroNX $host/PortDuplicator0.rtc:HiroNX
    rtcon $host/HiroNXGUI0.rtc:HIRO $host/PortDuplicator0.rtc:HIRO
    rtcon $host/ArmController0.rtc:HiroNX $host/PortDuplicator0.rtc:HiroNX
    rtcon $host/ArmController0.rtc:HIRO $host/PortDuplicator0.rtc:HIRO
    rtcon $host/PortDuplicator0.rtc:HiroNX0 $host/HiroNXPorvider0.rtc:HiroNX
    rtcon $host/PortDuplicator0.rtc:HIRO0 $host/HiroNXProvider0.rtc:HIRO
    rtcon $host/PortDuplicator0.rtc:HiroNX1 $host/HandManipProvider0.rtc:HiroNX
    rtcon $host/PortDuplicator0.rtc:HIRO1 $host/HandManipProvider0.rtc:HIRO
    rtact $host/HiroNXGUI0.rtc $host/HiroNXProvider0.rtc $host/ArmController0.rtc $host/PortDuplicator0.rtc $host/HandManipProvider0.rtc
}

set -e

# setup ros environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
source /opt/preinstalled/setup.bash
exec "$@"

