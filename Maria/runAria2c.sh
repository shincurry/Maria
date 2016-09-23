#!/bin/bash

#  runAria2.sh
#  Maria
#
#  Created by ShinCurry on 16/4/23.
#  Copyright © 2016年 ShinCurry. All rights reserved.

PID=`pgrep aria2c`

if [ ! -f "$USER_HOME/.aria2/aria2.session" ]
then
touch "$USER_HOME/.aria2/aria2.session"
fi

if [ -n "$PID" ]
then
echo "aria2c already run"
else

/usr/local/bin/aria2c --conf-path="${1}" -D
echo "run aria2c successfully."
fi
