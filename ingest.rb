
# A service to populate the db, with bitstamp data.
# Do not make more than 600 request per 10 minutes or we will ban your IP address.
# https://www.bitstamp.net/api/


require 'json'
require 'open-uri'
require 'pg'



class MyClient

  def initialize( db_params )
    @db_params = db_params 
    @threads = []
  end

  def start_client( url, interval )

    @threads << Thread.new {

      conn = PG::Connection.open( @db_params  )
      start_time = Time.now
      starting = true
      loop do
      begin
        open( url, "rb") do |read_file|
          json = <<-EOF 
            { 
              "url": "#{ url }", 
              "pid": "#{Process.pid}",
              "data": #{read_file.read}
            }
          EOF
          res = conn.exec_params( 'insert into events( t, msg, data) values( now()::timestamptz, $$order2$$, $1::json )', 
            [json] )
        end

        
        if starting
          puts "#{start_time} started successfully. #{url}" 
          starting = false
        end
        
      rescue
        begin
          # On error just record the error
          res = conn.exec_params( 'insert into events( t, msg, data) values( now()::timestamptz, $$error$$, $1::json )', 
            [$!.to_json] )
        rescue
          # if cant write db, then there's nothing else we can do, so write std-out
          puts "#{Time.now()}: exception error - #{$!}"
        end
      end
        # must be sleep when get exception too

      # try and schedule according to interval
      begin
        start_time = start_time + interval
        sleep_time = (start_time - Time.now ).to_i
      end while sleep_time < 0

      puts "sleep #{url} #{sleep_time}"
      sleep( sleep_time  )
    end 
    }
  end

  def wait()
    @threads.each() do |t|
      t.join()
    end
  end


end


db_params = { :dbname => 'test2', :user => 'meteo', :password => 'meteo' }

# res = conn.exec_params('SELECT $1::int AS a, $2::int AS b, $3::int AS c', [1, 2, nil])

client = MyClient.new( db_params )

client.start_client( 'https://www.bitstamp.net/api/order_book/', 60)
client.start_client( 'https://www.bitstamp.net/api/ticker/', 60)
client.start_client( 'https://api.btcmarkets.net/market/BTC/AUD/orderbook', 60)
client.start_client( 'https://api.btcmarkets.net/market/BTC/AUD/trades', 3 * 60)

client.wait()

  # 
  # i = 0
  # while true do
  #   begin
  #     # puts i 
  #     open("https://www.bitstamp.net/api/order_book/", "rb") do |read_file|
  #       res = conn.exec_params( 'insert into events( t, msg, data) values( now()::timestamptz, $$order$$, $1::json )', 
  #         [read_file.read] )
  #     end
  # 
  #     open("https://www.bitstamp.net/api/ticker/", "rb") do |read_file|
  #       res = conn.exec_params( 'insert into events( t, msg, data) values( now()::timestamptz, $$ticker$$, $1::json )', 
  #         [read_file.read] )
  #     end
  #   rescue
  #     begin
  #       # On error just record the error
  #       res = conn.exec_params( 'insert into events( t, msg, data) values( now()::timestamptz, $$error$$, $1::json )', 
  #           [$!.to_json] )
  #     rescue
  #       # if cant write db, then there's nothing else we can do, so write std-out
  #       puts "#{Time.now()}: exception error - #{$!}"
  #     end
  #   end
  # 
  #   if i == 0
  #     puts "started successfully."
  #   end
  # 
  #   i = i + 1
  #   sleep(60.0)
  # end

  # res.each do |row|
  #   puts row
  # end
  # 


