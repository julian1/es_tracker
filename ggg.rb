
require 'json'
require 'pg'
require 'date'


# s = '{"timestamp": "1411168092", "bids": [["395.24", "2.25000000"]]}'
# j = JSON.parse( s )
# puts "#{j['bids']}" 
# puts "data type #{j.class}" 
# abort()

conn = PG::Connection.open(:dbname => 'test', :user => 'meteo', :password => 'meteo' )

# res = conn.exec_params( 'select id, t, msg, data from queue where msg = $$order$$ order by id limit 1', [] )
res = conn.exec_params( 'select id, t, msg, data from queue order by id ', [] )

def dostuff( msg, t, data )
	
	if msg == 'order'
		#puts "#{msg } #{t}"
		bids = data['bids'].length
		asks = data['asks'].length
		ratio = (bids.to_f / asks.to_f ).round(3) 

		puts "#{t} total bids:#{bids} asks:#{asks} ratio:#{ratio}"
	end
end


res.each do |row|
	begin
		id = row['id'].to_i
		t = DateTime.parse( row['t'] ) 
		msg = row['msg']
		data = JSON.parse( row['data'] )
	rescue
		puts "Exception #{$!}"
	end

	# ok, we haven't got json - we've just got a string. 
	# it's not being parsed correctly to_json

	# puts id

	#puts "data type #{data.class}" 
	#puts " #{data['timestamp']}  " 
	#puts data

	dostuff(msg, t, data)
end
#

#uts "ratio #{(bids_sum/asks_sum*100.to_i) / 100 }"
