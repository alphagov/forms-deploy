#!/bin/bash

# Performs the forms-api database migration for the development
# environment (extract has to be applied via Data API console).
echo "Clearing dev and generating pg_dump"
./clear-tables.sh "dev"
./reset-table-sequences.sh "dev"
./pg-dump-data.sh "dev"

read -r -p "Once SQL has been run via data api press ENTER or ctl-C to quit"

echo "continuing"

./reset-table-sequences.sh "dev"

