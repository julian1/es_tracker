
require 'json'
require 'pg'
require 'date'

# class MyClass
# 
#   # ok, it's initialize that's called... not new
#   def initialize
#     @m = 123 
#   end
#   
#   def value
#     @m
#   end
# end
# 
# 
# 
# x = MyClass.new()
# 
# puts x.value()
# 
# abort()
# 


def process_queue( f )
	conn = PG::Connection.open(:dbname => 'test', :user => 'meteo', :password => 'meteo' )

	# res = conn.exec_params( 'select id, t, msg, data from queue where msg = $$order$$ order by id limit 1', [] )
	res = conn.exec_params( 'select id, t, msg, data from queue order by id ', [] )

	# we have to pass a function or block 
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



### 


class MyClass
   def initialize
      @m = []
   end

  def do_stuff( msg, t, data)
  #do_stuff = Proc.new do | msg, t, data | 
    # it would be very interesting to compute a series - based on the number of entries in
    # the order book within 10% of the price.
    if msg == 'order'
  # 		#puts "#{msg } #{t}"
       time = Time.at(data['timestamp'].to_i).to_datetime
  #     puts "book   #{time} " 
      bids = data['bids'].length
      asks = data['asks'].length
      ratio = (bids.to_f / asks.to_f ).round(3) 
      bids_sum = compute_sum(data['bids']) 
      asks_sum = compute_sum(data['asks']) 
      puts "#{time} total bids:#{bids} asks:#{asks} ratio:#{ratio}  bids_sum:#{bids_sum} asks_sum:#{asks_sum}"
  # lets try to just compute a series and look at it.
  # and do a regression...
  # we need to store state .. 
  # which means this should be a class
      @m << { :time => time, :bids => bids, :asks => asks } 
    end
    puts
    # how do we work with times - no we don't have to group them .
    # we can display a separate series.  
    if msg == 'ticker'
      last = data['last'].to_f 
      time = Time.at(data['timestamp'].to_i).to_datetime
      puts "ticker #{time} #{last}" 
    end
  #end
  end

end

# the question is does the price we can buy at move - in relation 
# we don't even need the ticker. 

x = MyClass.new()


f = proc { |a,b,c| x.do_stuff(a,b,c) }

process_queue( f )

# how can i refer to the variable ? 
puts x.m

