

select 
	e.id, 
	to_char( e.t, $$YYYY-MM-DD HH24:MI:SS$$ ) as t, 
	e.msg, 
	e.content->$$url$$ as url 
	from events e 
	where e.msg = $$order2$$ 
	order by id desc
	limit 30
;

