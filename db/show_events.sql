

select 
	e.id, 
	to_char( now() - e.t, $$HH24:MI$$ ) as t, 
	to_char( e.t, $$DD MM YYYY HH24:MI:SS$$ ) as time, 

	e.msg from events e 
	order by id desc

