
-- sudo -u postgres psql -f ./make_db.sql 

-- echo 'localhost:5432:*:meteo:meteo' > ~/.pgpass

-- expects to have the user meteo

create database test2; 

\c test2; 


create schema meteo authorization meteo;

CREATE TABLE events ( id serial primary key, t timestamptz, msg varchar(10), data json ); 
alter table events owner to meteo;



CREATE or replace PROCEDURAL LANGUAGE plpgsql;

-- Create a trigger function in PL/pgSQL.

CREATE FUNCTION notify_trigger() RETURNS trigger AS $$
DECLARE
BEGIN
 -- TG_TABLE_NAME is the name of the table who's trigger called this function
 -- TG_OP is the operation that triggered this function: INSERT, UPDATE or DELETE.
 execute 'NOTIFY ' || TG_TABLE_NAME || '_' || TG_OP;
 return new;
END;
$$ LANGUAGE plpgsql;
-- Create triggers on the test tables

CREATE TRIGGER table1_trigger BEFORE insert or update or delete on events execute procedure notify_trigger();





