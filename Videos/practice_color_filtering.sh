#!/bin/sh
#
# Copyright (c) 2016
# Author: Victor Arribas <v.arribas.urjc@gmail.com>
# License: GPLv3 <http://www.gnu.org/licenses/gpl-3.0.html>


if [ -z "$1" ] || [ "$1" = "--help" ]; then
cat<<EOF

##############################################################################
# This script brings the runtime environment to realize practice related
# with **Image Segmentation II**.
#
# Objetive is to play and recognize different color spaces and how color
# representation affects to image segmentation process.
# The student should find the proper thresholds to highlight the balls
# that appeas into videos.
#
# Exercises: 1a, 1b, 2a, 2b (run it with './practice_color_filtering.sh 1a')
#
# Hint: into ColorTuner, you can click a pixel to automatically obtain a
# threshold guess
#
# practice_color_filtering.sh - Copyright (c) 2016 Victor Arribas
##############################################################################

EOF
exit
fi

set -e
set -u


case "$1" in
1|1a|filter|filter-simple)
	video=pelota_roja.avi
	video_src=http://jderobot.org/store/amartinflorido/uploads/curso/pelota_roja.avi
	;;
1b|filter2)
	video=pelotas_roja_azul.avi
	video_src=http://jderobot.org/store/amartinflorido/uploads/curso/pelotas_roja_azul.avi
	;;
2|2a|filter-real)
	video=drone1.mp4
	video_src=http://jderobot.org/store/amartinflorido/uploads/curso/drone1.mp4
	;;
2b|filter-real2)
	video=drone2.mp4
	video_src=http://jderobot.org/store/amartinflorido/uploads/curso/drone2.mp4
	;;
esac

if [ ! -f $video ]; then
	wget $video_src -O $video
fi

PORT=7777
NAME=video
_cfg=fromfile.cfg
cat<<EOF>$_cfg
## Color Tuner (client)
Cameraview.Camera.Proxy=$NAME:tcp -h localhost -p $PORT

## Camera Server (server)
CameraSrv.Endpoints=default -h 0.0.0.0 -p $PORT
CameraSrv.NCameras=1
CameraSrv.Camera.0.Name=$NAME
CameraSrv.Camera.0.Uri=$video
CameraSrv.Camera.0.FramerateN=25
CameraSrv.Camera.0.FramerateD=1
CameraSrv.Camera.0.Format=RGB8
CameraSrv.Camera.0.ImageWidth=640
CameraSrv.Camera.0.ImageHeight=480
EOF

set +e
cameraserver --Ice.Config=$_cfg &
pid_camsrv=$!
sleep 5

colorTuner --Ice.Config=$_cfg
echo " exiting..."

kill -2 $pid_camsrv
echo "Exercise finalized."

