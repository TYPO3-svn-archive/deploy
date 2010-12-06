#!/bin/bash

function usage {
	echo "Usage:"
	echo "  $0 [-u <db user>} [-p <db pass>] [-h <db host>] [-d <database>] [-r] -t <target dir> [-f <regex filter>] [-n] [-a]"
	echo "  -u, -p, -h, -d    Database connection parameters"
	echo "  -t <target dir>   Directory where to files should go to"
	echo "  -f <regex filter> Regex filter for data (and for structure if -a is set)"
	echo "  -r                Retrieve database data automatically (no need to specifiy -u, -p, -h, -d)"
	echo "  -n                Negate the filter defined in -f"
	echo "  -a                If set the filter also applies while creating structure"
	echo ""
	exit $1
}


HOST="localhost"
RETRIEVEDBDATA=0
NEGATEFILTER=0
APPLYFILTERONSTRUCTURE=0

########## get argument-values
while getopts 'u:p:h:d:f:t:nra' OPTION ; do
    case "${OPTION}" in
        u)  USERNAME="${OPTARG}";;
        p)  PASSWORD="${OPTARG}";;
        h)  HOST="${OPTARG}";;
        d)  DATABASE="${OPTARG}";;
        f)  FILTER="${OPTARG}";;
        t)  TARGETDIR=`echo "${OPTARG}" | sed -e "s/\/*$//" `;; # delete last slash
        n)  NEGATEFILTER=1;;
		r)	RETRIEVEDBDATA=1;;
		a)  APPLYFILTERONSTRUCTURE=1;;
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
if [ -z $TARGETDIR ]; then echo "No target dir set."; exit 1; fi 

# Remote folder
if [[ $TARGETDIR == *:* ]] ; then 
	echo "Remote folders not supported yet"
	exit 1
fi

if [ ! -d $TARGETDIR ]; then
	mkdir "$TARGETDIR";
	echo "Create $TARGETDIR";
	if [ ! -d $TARGETDIR ]; then
		echo "Directory $TARGETDIR does not exists"
		exit 1 
	fi 	
fi 
echo "Exporting to $TARGETDIR"

echo "Deleting all *.sql files";
rm -f $TARGETDIR/*.sql

# Filter
if [ "$FILTER" == "" ]; 
	then FILTER=".*"; echo "No filtering" 
	else echo "Applying filter $FILTER";
fi
if [ "$NEGATEFILTER" -ne 0 ] ; then GREPPARAM="-v"; else GREPPARAM=""; fi

# get all available tables
TABLES=`mysql -u$USERNAME -p$PASSWORD -h$HOST -BNe "show tables" $DATABASE`

echo ""
echo "Exporting structure"
echo "-------------------"
for table in $TABLES ;
do
	if [ "$APPLYFILTERONSTRUCTURE" -eq 0 ] || echo "`basename $table`" | grep $GREPPARAM "$FILTER" > /dev/null
	then
		echo " -> $TARGETDIR/$table.structure.sql";
		mysqldump -u$USERNAME -p$PASSWORD -h$HOST $DATABASE $table --no-data | egrep -v ^-- | sed -e 's/ AUTO_INCREMENT=[0-9]\+//' > "$TARGETDIR/$table.structure.sql"
	fi
done;

echo ""
echo "Exporting data"
echo "--------------"
for table in $TABLES ;
do
	if echo "`basename $table`" | egrep $GREPPARAM "$FILTER" > /dev/null
	then
		echo " -> $TARGETDIR/$table.data.sql";
		mysqldump -u$USERNAME -p$PASSWORD -h$HOST $DATABASE $table --no-create-db --no-create-info --skip-extended-insert --order-by-primary | grep -v ^-- > "$TARGETDIR/$table.data.sql"
	fi
done;