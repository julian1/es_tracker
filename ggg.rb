
require 'json'
require 'pg'


# s = '{"timestamp": "1411168092", "bids": [["395.24", "2.25000000"]]}'
# j = JSON.parse( s )
# puts "#{j['bids']}" 
# puts "data type #{j.class}" 
# abort()

conn = PG::Connection.open(:dbname => 'test', :user => 'meteo', :password => 'meteo' )

res = conn.exec_params( 'select t, msg, data from queue where msg = $$order$$ limit 1', [] )

res.each do |row|
	t = row['t']
	msg = row['msg']

	data = JSON.parse( row['data'] )

	# ok, we haven't got json - we've just got a string. 
	# it's not being parsed correctly to_json


	puts "#{msg } #{t}"


	puts "data type #{data.class}" 
	puts " #{data['timestamp']}  " 
	#puts data
end
#

#uts "ratio #{(bids_sum/asks_sum*100.to_i) / 100 }"
