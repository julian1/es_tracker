
psql -d test -c 'select id, to_char( t, $$YYYYMMDD HH12:MI:SS$$ ), msg from queue '

