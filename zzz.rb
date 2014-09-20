
# require 'json'
# require 'open-uri'
require 'pg'


conn = PG::Connection.open(:dbname => 'test', :user => 'meteo', :password => 'meteo' )

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
