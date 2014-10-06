
begin;
-- ok, readonly and writeonly users

CREATE FUNCTION exec(text) returns text
language plpgsql volatile
AS $$
	BEGIN
	EXECUTE $1;
	RETURN $1;
	END;
$$;
-- grant all on function exec(text) to public;


alter table events owner to postgres ;
alter function enqueue( VARCHAR(10), json ) owner to postgres;
alter sequence trades_id_seq owner to postgres;

-- change later for prod
create role events_ro password 'events_ro' login;  
create role events_wr password 'events_wr' login;  

-- read-only role
select exec('grant usage on schema '||current_schema()||' to events_ro' ); 
grant select on table events to events_ro; 

-- it needs write on events, to be able to call the enqueue func
-- all allows creation, so limit to usage
select exec('grant usage on schema '||current_schema()||' to events_wr' ); 
grant all on table events to events_wr; 
grant execute on function enqueue( VARCHAR(10), json ) to events_wr; 
grant usage on sequence trades_id_seq to events_wr;  

commit;

