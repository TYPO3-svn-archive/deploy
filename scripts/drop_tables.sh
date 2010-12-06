#!/bin/bash

function usage {
	echo "Usage:"
	echo "  $0 [-u <db user>} [-p <db pass>] [-h <db host>] [-d <database>] [-r]"
	echo "  -u, -p, -h, -d    Database connection parameters"
	echo "  -r                Retrieve database data automatically (no need to specifiy -u, -p, -h, -d)"
	echo ""
	exit $1
}


HOST="localhost"
RETRIEVEDBDATA=0

########## get argument-values
while getopts 'u:p:h:d:r' OPTION ; do
    case "${OPTION}" in
        u)  USERNAME="${OPTARG}";;
        p)  PASSWORD="${OPTARG}";;
        h)  HOST="${OPTARG}";;
        d)  DATABASE="${OPTARG}";;
		r)	RETRIEVEDBDATA=1;;
        \?) echo; usage 1;;
    esac
done

# Database parameters
if [ "$RETRIEVEDBDATA" -ne 0 ] ; then
	echo "Retrieving db data from local.xml"
	. `cd -- "$(dirname -- "$0")" && pwd`/retrieve_dbdata.sh
fi
if [ "$USERNAME" == "" ] || [[ "$USERNAME" == *{{*}}* ]]; then echo "No username found"; exit 1; fi
if [ "$DATABASE" == "" ] || [[ "$DATABASE" == *{{*}}* ]] ; then echo "No dbname found"; exit 1; fi
if [ "$HOST" == "" ] || [[ "$HOST" == *{{*}}* ]]; then echo "No hostname found"; exit 1; fi
if [ "$PASSWORD" == "" ] || [[ "$PASSWORD" == *{{*}}* ]]; then echo "No password found"; exit 1; fi
echo "Database mysql://$USERNAME:$PASSWORD@$HOST/$DATABASE"

mysql -u$USERNAME -p$PASSWORD -h$HOST -BNe "show tables" $DATABASE | tr '\n' ',' | sed -e 's/,$//' | awk '{print "SET FOREIGN_KEY_CHECKS = 0;DROP TABLE IF EXISTS " $1 ";SET FOREIGN_KEY_CHECKS = 1;"}' | mysql -u$USERNAME -p$PASSWORD -h$HOST $DATABASE
