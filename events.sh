

psql -d test2 -c 'select e.id, to_char( e.t, $$YYYYMMDD HH24:MI:SS$$ ), e.msg from events e '

