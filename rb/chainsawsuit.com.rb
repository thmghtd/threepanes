# Copyright 2009 Max Howell
require 'threepanes'

puts "chainsawsuit"
puts "Surreal"

get_rss 'http://www.chainsawsuit.com/feed.xml' do |item|
  item.description =~ /src="(.*?)"/
  comic $1, item.pubDate, item.title
end