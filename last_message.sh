
psql -d test -c 'select id, to_char( t, $$HH12:MI:SS$$ ) as last, to_char( now() - t, $$HH24::MI:SS$$ ) as period,msg from queue order by id desc limit 1 '

