
-- should not specify the database or even schema, 
-- Ideally also no dropping only renaming etc  
-- which should be specified external to the script

begin;

CREATE TABLE trades ( 
	id serial primary key, 
	t timestamptz, 
	msg varchar(10), 
	data json 
); 



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

CREATE TRIGGER table1_trigger 
BEFORE insert or update or delete 
on trades 
execute procedure notify_trigger();


commit;

