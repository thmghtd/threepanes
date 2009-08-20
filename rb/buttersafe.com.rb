# Copyright 2009 Max Howell
require 'threepanes'

puts "Buttersafe"
puts "Surreal"

get_rss 'http://feeds.feedburner.com/Buttersafe' do |item|
  get(item.link) =~ %r[buttersafe.com/(comics/\d\d\d\d-\d\d-\d\d-.*?\.jpg)]
  comic $1, item.pubDate, item.title
end