# Copyright 2009 Max Howell
require 'threepanes'

puts "Diesel Sweeties"
puts "Sitcom"

get_rss 'http://www.dieselsweeties.com/ds-unifeed.xml' do |item|
  item.description =~ %r[src="(http://(www.)?dieselsweeties.com/strips/.*?)"]
  comic $1, item.pubDate, item.title if $1
end