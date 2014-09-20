
require 'json'
require 'pg'
require 'date'

# what about a running service where we want updating ? 
# a class ..
# issue is the transition - from historic to updated.,
# actually we can handle this. processed 
# actually it's really simple --- we just take all event ids that are greater than the 
# last one we processed... 




def process_resultset( res, f )
  # process a result set with events - we have to pass a function or block 
  id = -1
  res.each do |row|
    begin
      # process id, first to avoid exceptions being reprocessed 
      id = row['id'].to_i
      t = DateTime.parse( row['t'] ) 
      msg = row['msg']
      data = JSON.parse( row['data'] )
      f.call(id, msg, t, data)
    rescue
      $stderr.puts "Exception id: #{id} error: #{$!}"
    end
  end
  id 
end


def process_historic_events(  conn, f )
  res = conn.exec_params( 'select id, t, msg, data from events order by id ', [] )
  process_resultset( res, f )

  # close res
end


# need to pass the id
def process_current_events( conn, last_id, f )
  while true
    begin 
      conn.async_exec "LISTEN events_insert"
      conn.wait_for_notify do |channel, pid, payload|
        puts "Received a NOTIFY on channel #{channel} #{pid} #{payload}"
        res = conn.exec_params( 'select id, t, msg, data from events where id > $1 order by id ', [last_id] )
        last_id = process_resultset( res, f )
        # close res 
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

  def do_stuff( id, msg, t, data)

      puts "processing event #{id}"

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

conn = PG::Connection.open(:dbname => 'test', :user => 'meteo', :password => 'meteo' )

x = MyClass.new()
f = proc { |a,b,c,d| x.do_stuff(a,b,c,d) }



last = process_historic_events( conn, f )

#puts "last id #{last}"
#last = 940
process_current_events( conn, last , f )




# need json keys to array - for the show messages

