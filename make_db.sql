
-- sudo -u postgres psql -f ./make_db.sql 

-- echo 'localhost:5432:*:meteo:meteo' > ~/.pgpass

drop database if exists test; 
drop user if exists meteo ; 
create user meteo password 'meteo'; 

create database test; 

\c test; 


create schema meteo authorization meteo;

-- change name to queue
CREATE TABLE queue ( id serial primary key, t timestamptz, msg varchar(10), data json ); 
alter table queue owner to meteo;

