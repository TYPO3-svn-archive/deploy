#!/bin/bash

. `cd -- "$(dirname -- "$0")" && pwd`/retrieve_dbdata.sh

echo "mysql -u$USERNAME -p$PASSWORD -h$HOST $DATABASE"
