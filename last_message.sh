
psql -d test -c 'select id, to_char( t, $$HH12:MI:SS$$ ) as last, to_char( now() - t, $$HH24::MI:SS$$ ) as period,msg from trades where id = (select max(id) from trades)'

