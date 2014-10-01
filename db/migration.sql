
-- could add other fields,



CREATE OR REPLACE FUNCTION enqueue( msg VARCHAR(10), data json )
RETURNS void AS $$
BEGIN
  INSERT INTO events( t, origin, msg, data )
  VALUES (
    now()::timestamptz,
	left( 
		coalesce( inet_client_addr()::varchar, 'none')
		||','||
		coalesce( pg_backend_pid()::varchar, 'none')
		||','||
		coalesce( user::varchar, 'none')
		, 40 
	),
    msg,
    data
  );
END;
$$ LANGUAGE plpgsql;


