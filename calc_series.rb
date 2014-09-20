
require 'json'
require 'pg'
require 'date'

# what about a running service where we want updating ? 
# a class ..
# issue is the transition - from historic to updated.,
# actually we can handle this. processed 
# actually it's really simple --- we just take all event ids that are greater than the 
# last one we processed... 




def process_events( res, f )

    # we have to pass a function or block 
  processed_id = -1
  res.each do |row|
    begin
      id = row['id'].to_i
      t = DateTime.parse( row['t'] ) 
      msg = row['msg']
      data = JSON.parse( row['data'] )
      f.call(msg, t, data)
      processed_id = id
    rescue
      $stderr.puts "Exception #{$!}"
    end
  end
  processed_id 
end


def process_historic_events(  f )
  conn = PG::Connection.open(:dbname => 'test', :user => 'meteo', :password => 'meteo' )
  # res = conn.exec_params( 'select id, t, msg, data from events where msg = $$order$$ order by id limit 1', [] )
  res = conn.exec_params( 'select id, t, msg, data from events order by id ', [] )
  process_events( res, f )
end



def process_current_events2( conn, f )
  while true
    begin 
      conn.async_exec "LISTEN events_insert"

      conn.wait_for_notify do |channel, pid, payload|
        puts "Received a NOTIFY on channel #{channel}"
        puts "from PG backend #{pid}"
        puts "saying #{payload}"
      end
    ensure
      conn.async_exec "UNLISTEN *"
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


# do_stuff = Proc.new do | msg, t, data | 
# end 
 

class MyClass
  def initialize
    @m = []
  end

  def do_stuff( msg, t, data)
    if msg == 'order'
#       # puts "#{time} total bids:#{bids} asks:#{asks} ratio:#{ratio}  bids_sum:#{bids_sum} asks_sum:#{asks_sum}"
#       #  @m << { :time => time, :bids => bids, :asks => asks } 

      time = Time.at(data['timestamp'].to_i).to_datetime
      top_bid = data['bids'][0][0]
      bids = data['bids'].length
      asks = data['asks'].length
      ratio = (bids.to_f / asks.to_f ).round(3) 
      bids_sum = compute_sum(data['bids']) 
      asks_sum = compute_sum(data['asks']) 
      sum_ratio = (bids_sum.to_f / asks_sum.to_f).round(3) 

      #puts "#{t} top_bid #{top_bid} total bids:#{bids} asks:#{asks} ratio:#{ratio}  bids_sum:#{bids_sum} asks_sum:#{asks_sum} ratio:#{sum_ratio}"
  # 
      puts "#{time}, #{top_bid}, #{sum_ratio}"

    end
  end

end

# the question is does the price we can buy at move - in relation 
# we don't even need the ticker. 

x = MyClass.new()
f = proc { |a,b,c| x.do_stuff(a,b,c) }
last = process_historic_events( f )

puts "last id #{last}"






# need json keys to array - for the show messages

