
psql -d test -c 'select id, to_char( t, $$HH12:MI:SS$$ ), msg from queue '

