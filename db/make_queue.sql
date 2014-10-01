
-- sudo -u postgres psql -f ./make_db.sql

-- echo 'localhost:5432:*:meteo:meteo' > ~/.pgpass

-- should expect any user, or drop anything


--------------------------------------------------------------------
CREATE TABLE events (
	id serial primary key,
	t timestamptz,
	origin varchar(40),
	msg varchar(10),
	content json
);


--------------------------------------------------------------------
-- A trigger function for events
CREATE or replace PROCEDURAL LANGUAGE plpgsql;

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
BEFORE insert or update or delete on events 
execute procedure notify_trigger();

--------------------------------------------------------------------
-- Function to enqueue events


CREATE OR REPLACE FUNCTION enqueue( msg VARCHAR(10), content json )
RETURNS void AS $$
BEGIN
  INSERT INTO events( t, origin, msg, content )
  VALUES (
    now()::timestamptz,
	left( 
		coalesce( inet_client_addr()::varchar, 'none')
		||','||
		coalesce( user::varchar, 'none')
		, 40 
	),
    msg,
    content
  );
END;
$$ LANGUAGE plpgsql;

