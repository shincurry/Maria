#!/bin/sh

#  shutdownAria2.sh
#  Maria
#
#  Created by ShinCurry on 16/4/23.
#  Copyright © 2016年 ShinCurry. All rights reserved.

PID=`pgrep aria2c`
if [ -n "$PID" ]
then
    kill $PID
    echo "aria2c killed."
else
    echo "aria2c already closed."
fi