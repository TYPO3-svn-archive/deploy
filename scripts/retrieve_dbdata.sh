HTDOCS=`cd -- "$(dirname -- "$0")" && pwd`/../htdocs
CONFIGFILE=$HTDOCS/typo3conf/localcontext.php

if [ ! -e $CONFIGFILE ]; then
CONFIGFILE=$HTDOCS/typo3conf/localconf.php
fi

USERNAME=`cat $CONFIGFILE | grep "^\\\$typo_db_username =" | tail -1 | sed -e 's/.*= .//g' | sed -e 's/.;.*//g'`
HOST=`cat $CONFIGFILE | grep "^\\\$typo_db_password =" | tail -1 | sed -e 's/.*= .//g' | sed -e 's/.;.*//g'`
PASSWORD=`cat $CONFIGFILE | grep "^\\\$typo_db_host =" | tail -1 | sed -e 's/.*= .//g' | sed -e 's/.;.*//g'`
DATABASE=`cat $CONFIGFILE | grep "^\\\$typo_db =" | tail -1 | sed -e 's/.*= .//g' | sed -e 's/.;.*//g'`
