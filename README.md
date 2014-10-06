
    apt-get install postgresql-9.3
    sudo apt-get install git

    git clone git@github.com:julian1/es_tracker

    sudo vim /etc/postgresql/9.3/main/pg_hba.conf 
    sudo vim /etc/postgresql/9.3/main/postgresql.conf 

    sudo apt-get install ruby
    vim Gemfile 
    sudo gem install bundler
    sudo aptitude install ruby1.9.1-dev
    sudo apt-get install libpq-dev
    sudo apt-get install make
    bundle install


  --------------------------
    -- should be explicit about db, and schema 

    cd db
    sudo -u postgres psql -p 5434 -c 'create database test'
    sudo -u postgres psql -p 5434 -d test -f all.sql 

    -------
    > pg_hba.conf
    hostssl    all            postgres      0.0.0.0/0               reject 
    local      all             postgres                             peer
    hostssl    all             all        0.0.0.0/0                 md5

    
    > postgresql.conf
    listen_addresses = '*'          # what IP address(es) to listen on;

