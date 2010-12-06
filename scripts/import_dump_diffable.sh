#!/bin/bash

function usage {
	echo "Usage:"
	echo "  $0 [-u <db user>} [-p <db pass>] [-h <db host>] [-d <database>] [-r] -s <source dir> [-f <regex filter>] [-n] [-a]"
	echo "  -u, -p, -h, -d    Database connection parameters"
	echo "  -s <source dir>   Directory where to files come from. Remote folders are supported here"
	echo "  -f <regex filter> Regex filter for data (and for structure if -a is set)"
	echo "  -r                Retrieve database data automatically (no need to specifiy -u, -p, -h, -d)"
	echo "  -n                Negate the filter defined in -f"
	echo ""
	exit $1
}


HOST="localhost"
RETRIEVEDBDATA=0
NEGATEFILTER=0

########## get argument-values
while getopts 'u:p:h:d:f:s:nr' OPTION ; do
    case "${OPTION}" in
        u)  USERNAME="${OPTARG}";;
        p)  PASSWORD="${OPTARG}";;
        h)  HOST="${OPTARG}";;
        d)  DATABASE="${OPTARG}";;
        f)  FILTER="${OPTARG}";;
        s)  SOURCEDIR=`echo "${OPTARG}" | sed -e "s/\/*$//" `;; # delete last slash
        n)  NEGATEFILTER=1;;
		r)	RETRIEVEDBDATA=1;;
        \?) echo; usage 1;;
    esac
done

# Database parameters
if [ "$RETRIEVEDBDATA" -ne 0 ] ; then
	echo "Retrieving db data automatically"
	. `cd -- "$(dirname -- "$0")" && pwd`/retrieve_dbdata.sh
fi
if [ "$USERNAME" == "" ] || [[ "$USERNAME" == *{{*}}* ]]; then echo "No username found"; exit 1; fi
if [ "$DATABASE" == "" ] || [[ "$DATABASE" == *{{*}}* ]] ; then echo "No dbname found"; exit 1; fi
if [ "$HOST" == "" ] || [[ "$HOST" == *{{*}}* ]]; then echo "No hostname found"; exit 1; fi
if [ "$PASSWORD" == "" ] || [[ "$PASSWORD" == *{{*}}* ]]; then echo "No password found"; exit 1; fi
echo "Database mysql://$USERNAME:$PASSWORD@$HOST/$DATABASE"

# Dir
if [ -z $SOURCEDIR ]; then echo "No source dir set."; exit 1; fi 

# Remote folder
if [[ $SOURCEDIR == *:* ]] ; then 
	echo "Detected remote folder"; 
	TMPDIR=".tmp_import.`date +%s`";
	echo "Copy files from $SOURCEDIR to $TMPDIR"; 
	scp -rq "$SOURCEDIR/" "$TMPDIR"
	SOURCEDIR=$TMPDIR
fi

if [ ! -d $SOURCEDIR ]; then echo "Directory $SOURCEDIR does not exists"; exit 1; fi 
echo "Importing from $SOURCEDIR"


# Filter
if [ "$FILTER" == "" ]; 
	then FILTER=".*"; echo "No filtering" 
	else echo "Applying filter $FILTER";
fi
if [ "$NEGATEFILTER" -ne 0 ] ; then GREPPARAM="-v"; else GREPPARAM=""; fi

for i in "structure" "data";
do
	echo ""
	echo "Importing $i"
	echo "-------------------"
	for filename in $SOURCEDIR/*.$i.sql;
	do
		if echo "`basename $filename`" | grep $GREPPARAM "$FILTER" > /dev/null
		then
			echo " -> $filename"
			mysql -u$USERNAME -p$PASSWORD -h$HOST $DATABASE < $filename
		fi
	done;
done;


if [ -d "$TMPDIR" ] ; then rm -rf "$TMPDIR"; fi
