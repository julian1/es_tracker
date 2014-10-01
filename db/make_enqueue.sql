
-- could add other fields,
-- select user ||','||pg_backend_pid()||','||inet_client_addr() as origin;

-- select enqueue( 'test', '123'::json );

CREATE OR REPLACE FUNCTION enqueue( msg VARCHAR(10), data json ) 
RETURNS void AS $$

BEGIN
  INSERT INTO events( t, msg, data) 
  VALUES ( now()::timestamptz, msg, data );
END;

$$ LANGUAGE plpgsql;

