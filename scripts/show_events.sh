
psql -d test -c 'select id, to_char( t, $$YYYYMMDD HH24:MI:SS$$ ), msg from events'

