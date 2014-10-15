
# A service to populate the event queue, with data.

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
          # we should not be exposing this, instead use a queue/stream/events writer.
          conn.exec_params( 'select enqueue( $$order2$$, $1::json )', [json] )
        end


        if starting
          puts "#{start_time} started successfully. #{url}"
          starting = false
        end

      rescue
        begin
          # On error just record the error
          json = <<-EOF
            {
              "url": "#{ url }",
              "pid": "#{Process.pid}",
              "data": #{$!.to_json}
            }
          EOF
          conn.exec_params( 'select enqueue( $$error$$, $1::json )', [json] )
        rescue
          # if we coulldn't write the db, then there's nothing else to do but write std-out
	        # or file	
          puts "#{Time.now()}: exception error - #{$!}"
        end
      end
        # must be sleep when get exception too

      # try and schedule actions on a multiple of the timing interval
      begin
        start_time = start_time + interval
        sleep_time = (start_time - Time.now ).to_i
      end while sleep_time < 0

      # puts "sleep #{url} #{sleep_time}"
      sleep( sleep_time  )
    end
    }
  end

  def run()
    @threads.each() do |t|
      t.join()
    end
  end


end


db_params = {
	:host => '127.0.0.1',
	:dbname => 'prod',
	:port => 5432,
	:user => 'events_wr',
	:password => 'events_wr'

}


client = MyClient.new( db_params )

client.start_client( 'https://www.bitstamp.net/api/order_book/', 60)
client.start_client( 'https://www.bitstamp.net/api/ticker/', 60)

client.start_client( 'https://api.btcmarkets.net/market/BTC/AUD/orderbook', 60)
client.start_client( 'https://api.btcmarkets.net/market/BTC/AUD/trades', 3 * 60)

# error tracking should record the url we attept to store to.

# we should be doing all this on a single http connction
# also,

### test for errors
###client.start_client( 'http://data.bter.com/api2/2/depth/btc_usd', 60 )


# bter
client.start_client( 'http://data.bter.com/api/1/depth/btc_usd', 60 )
client.start_client( 'http://data.bter.com/api/1/depth/btsx_btc', 60 )
client.start_client( 'http://data.bter.com/api/1/depth/btc_bitusd' , 60 )
client.start_client( 'http://data.bter.com/api/1/depth/bitusd_usd', 60 )
client.start_client( 'http://data.bter.com/api/1/depth/pts_btc', 60 )

client.start_client( 'http://data.bter.com/api/1/depth/nbt_btc', 60 ) # nubits
client.start_client( 'http://data.bter.com/api/1/depth/nxt_btc', 60 ) # nxt
client.start_client( 'http://data.bter.com/api/1/depth/xcp_btc', 60 ) # counterparty
client.start_client( 'http://data.bter.com/api/1/depth/msc_btc', 60 ) # mastercoin

client.start_client( 'http://data.bter.com/api/1/marketlist', 5 * 60 ) # total exchange stats


client.run()

