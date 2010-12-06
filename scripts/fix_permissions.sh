#!/bin/bash

SCRIPTPATH=`cd -- "$(dirname -- "$0")" && pwd`

if [ "$1" = "" ]
  then InputDir="$SCRIPTPATH/../"
  else InputDir="$1"
fi

echo chmod -R u+w,g=u,o=u-w $InputDir
chmod -R u+w,g=u,o=u-w $InputDir

echo chgrp -R www-data $InputDir
chgrp -R www-data $InputDir

echo find $InputDir -type d -exec chmod g+s {} \;
find $InputDir -type d -exec chmod g+s {} \;