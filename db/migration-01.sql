
-- function to wrap the event insert and table renaming 

begin;

alter table trades rename to events;

alter table events add column origin varchar(40 );

alter table events rename column data to content ;

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

commit;
