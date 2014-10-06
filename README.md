
    -- should be explicit about db, and schema 

    cd db
    sudo -u postgres psql -p 5434 -c 'create database test'
    sudo -u postgres psql -p 5434 -d test -f all.sql 


    > pg_hba.conf
	hostssl    all            postgres      0.0.0.0/0               reject 
	local      all             postgres                             peer
	hostssl    all             all        0.0.0.0/0                 md5

    
    > postgresql.conf

    listen_addresses = '*'          # what IP address(es) to listen on;

