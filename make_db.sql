
-- sudo -u postgres psql -f ./make_db.sql 

-- echo 'localhost:5432:*:meteo:meteo' > ~/.pgpass

drop database if exists test; 
drop user if exists meteo ; 
create user meteo password 'meteo'; 

create database test; 

\c test; 


create schema meteo authorization meteo;


CREATE TABLE trades ( id serial primary key, t timestamptz, msg varchar(10), data json ); 
alter table trades owner to meteo;

