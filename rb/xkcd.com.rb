# Copyright 2009 Max Howell
require 'threepanes'

puts "xkcd"
puts "Geek"

get_rss 'http://xkcd.com/rss.xml' do |item|
  item.description =~ /src="(.*?)"/
  comic $1, item.pubDate, item.title
end