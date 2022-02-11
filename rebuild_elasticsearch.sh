#!/bin/bash

# Shell script custom CSI Piemonte per misurare la durata del processo di Elastic Search che esegue la rebuild dell'indice.

echo "Elasticsearch rebuild started"
STARTDATETIME=$(date +%s)

# Modificare il valore di RAILS_ENV (dev/qa/demo/tu/production) a seconda dell'ambiente di esecuzione
no_proxy=dv-ap-be-ruby-pg-nextcrm.site02.nivolapiemonte.it,.nivolapiemonte.it,.csi.it,.local,127.0.0.1,::1,locahost RAILS_ENV="dev" rake searchindex:rebuild

ENDDATETIME=$(date +%s)
DIFFSECS=$(echo $(( ENDDATETIME - STARTDATETIME )))

echo "Elasticsearch rebuild endend"

echo "|> startDatetime -> ${STARTDATETIME}"
echo "|> endDatetime -> ${ENDDATETIME}"
echo "|> Diff in seconds -> ${DIFFSECS}"
