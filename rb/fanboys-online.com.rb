# Copyright 2009 Max Howell
require 'threepanes'

puts "F@NB0Y$"
puts "Gamer"

get_rss 'http://fanboys-online.com/rss/comic.xml' do |item|
  item.description =~ %r[src="http://fanboys-online.com/thumbs/(\d\d\d\d\d\d\d\d\.jpg)"]
  comic "comics/#{$1}", item.pubDate, item.title
end