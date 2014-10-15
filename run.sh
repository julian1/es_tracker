set -x
psql -h 127.0.0.1 -U events_ro -d prod -f $1 

