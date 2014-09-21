
psql -d test -c 'select id, to_char( t, $$HH12:MI:SS$$ ) as time, msg from queue where msg = $$error$$ '

