
require 'json'
require 'open-uri'



json = nil
open("http://www.bitstamp.net/api/order_book/", "rb") do |read_file|
	json = read_file.read
end


parsed = JSON.parse(json)


puts "total bids #{parsed['bids'].length}"
puts "total asks #{parsed['asks'].length}"
puts

bids_sum = 0
parsed['bids'].each do |i|
	price = i[0].to_f
	quantity = i[1].to_f
	bids_sum += price * quantity
end

asks_sum = 0
parsed['asks'].each do |i|
	price = i[0].to_f
	quantity = i[1].to_f
	asks_sum += price * quantity
end

puts "asks sum is #{asks_sum}"
puts "bids sum is #{bids_sum}"


puts "ratio #{bids_sum/asks_sum }"
