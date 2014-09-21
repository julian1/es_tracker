
-- sudo -u postgres psql -f ./make_db.sql 

-- echo 'localhost:5432:*:meteo:meteo' > ~/.pgpass

drop database if exists test; 
drop user if exists meteo ; 
create user meteo password 'meteo'; 

create database test; 

\c test; 


create schema meteo authorization meteo;

-- need to change name to events
-- change name to events
CREATE TABLE events ( id serial primary key, t timestamptz, msg varchar(10), data json ); 
alter table events owner to meteo;





