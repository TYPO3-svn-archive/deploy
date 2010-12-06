#!/bin/bash

SCRIPTPATH=`cd -- "$(dirname -- "$0")" && pwd`

# find ../htdocs/typo3temp -type f -mtime +28 -delete
find "$SCRIPTPATH/../htdocs/typo3temp" -type f -delete
rm -rf "$SCRIPTPATH/../htdocs/typo3conf/temp_CACHED*.php"
rm -rf "$SCRIPTPATH/../htdocs/typo3temp/sessions*"
