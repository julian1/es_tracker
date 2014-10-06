set -x

sudo -u postgres psql -p 5434 -c 'drop database if exists test' || exit
sudo -u postgres psql -p 5434 -c 'drop user if exists events_ro'|| exit
sudo -u postgres psql -p 5434 -c 'drop user if exists events_wr'|| exit
sudo -u postgres psql -p 5434 -c 'create database test' || exit


pushd db
sudo -u postgres psql -p 5434 -d test -f all.sql 
popd

