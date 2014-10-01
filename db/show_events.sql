

select 
	e.id, 
	to_char( now() - e.t, $$HH24:MI:SS$$ ) as d, 
	to_char( e.t, $$YYYY-MM-DD HH24:MI:SS$$ ) as t, 
	e.origin as origin,
	e.msg 
	from events e 
	order by id desc
	limit 30
;

