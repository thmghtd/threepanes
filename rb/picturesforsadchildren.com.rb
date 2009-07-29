# Copyright 2009 Max Howell
require 'threepanes'

puts "Pictures for Sad Children"
puts "Bizarre"

get_rss 'http://www.rsspect.com/rss/pfsc.xml' do |item|
  item.description =~ /src="(.*?)"/
  comic $1, item.pubDate, item.title
end