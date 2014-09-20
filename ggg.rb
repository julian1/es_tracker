
require 'json'
require 'pg'
require 'date'



def process_queue( f )
	conn = PG::Connection.open(:dbname => 'test', :user => 'meteo', :password => 'meteo' )

	# res = conn.exec_params( 'select id, t, msg, data from queue where msg = $$order$$ order by id limit 1', [] )
	res = conn.exec_params( 'select id, t, msg, data from queue order by id ', [] )

	# we have to pass a function or block 
	# def processqueue(
	res.each do |row|
		begin
			id = row['id'].to_i
			t = DateTime.parse( row['t'] ) 
			msg = row['msg']
			data = JSON.parse( row['data'] )
			f.call(msg, t, data)
		rescue
			puts "Exception #{$!}"
		end
	end
end


def compute_sum(data) 
  bids_sum = 0
  data.each do |i|
    price = i[0].to_f
    quantity = i[1].to_f
    bids_sum += price * quantity
  end
  bids_sum.to_i
end


do_stuff = Proc.new do | msg, t, data | 
	
	if msg == 'order'
		#puts "#{msg } #{t}"
		bids = data['bids'].length
		asks = data['asks'].length
		ratio = (bids.to_f / asks.to_f ).round(3) 

		bids_sum = compute_sum(data['bids']) 
		asks_sum = compute_sum(data['asks']) 
#		puts "sum #{bids_sum}"	

		puts "#{t} total bids:#{bids} asks:#{asks} ratio:#{ratio}  bids_sum:#{bids_sum} asks_sum:#{asks_sum}"
	end
end


process_queue( do_stuff)


