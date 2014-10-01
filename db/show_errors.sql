

select 
	e.id, 
	to_char( now() - e.t, $$HH24:MI::SS$$ ) as t, 
	to_char( e.t, $$DD MM YYYY HH24:MI:SS$$ ) as time, 
	e.msg, 
	e.data  
from events e 
where e.msg = $$error$$ 
order by id desc
;




