
# A service to populate the db, with bitstamp data.
# Do not make more than 600 request per 10 minutes or we will ban your IP address.
# https://www.bitstamp.net/api/

require 'json'
require 'open-uri'
require 'pg'

# = 1 / second

## psql -d test -c 'select id, data::json->$$timestamp$$  from events'

conn = PG::Connection.open(:dbname => 'test', :user => 'meteo', :password => 'meteo' )
# res = conn.exec_params('SELECT $1::int AS a, $2::int AS b, $3::int AS c', [1, 2, nil])


i = 0
while true do
	begin
    # puts i 
    open("https://www.bitstamp.net/api/order_book/", "rb") do |read_file|
      res = conn.exec_params( 'insert into events( t, msg, data) values( now()::timestamptz, $$order$$, $1::json )', 
        [read_file.read] )
    end

    open("https://www.bitstamp.net/api/ticker/", "rb") do |read_file|
      res = conn.exec_params( 'insert into events( t, msg, data) values( now()::timestamptz, $$ticker$$, $1::json )', 
        [read_file.read] )
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

  if i == 0
    puts "started successfully."
  end

	i = i + 1
	sleep(60.0)
end

# res.each do |row|
# 	puts row
# end
# 

