
# psql -d test2 -c 'select id, now() - t, to_char( t, $$YYYYMMDD HH24:MI:SS$$ ), msg  , data->$$url$$ as url from events  '

psql -d test2 -c 'select e.id, to_char( e.t, $$YYYYMMDD HH24:MI:SS$$ ) as t, e.msg, e.data->$$url$$ as url from events e where e.msg = $$order2$$ order by id'

