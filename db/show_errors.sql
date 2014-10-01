

select 
	e.id, 
	to_char( now() - e.t, $$HH24:MI::SS$$ ) as d, 
	to_char( e.t, $$YYYY-MM-DD HH24:MI:SS$$ ) as t, 
	e.origin as origin,
	e.msg, 
	e.data  
from events e 
where e.msg = $$error$$ 
order by id desc
;




