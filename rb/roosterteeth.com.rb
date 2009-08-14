# Copyright 2009 Max Howell
require 'threepanes'

puts "Rooster Teeth"
puts "Gamer"

get_rss 'http://roosterteeth.com/_rss/news.rss' do |item|
  item.description =~ /src=(.*?)t.jpg/
  comic "#{$1}.jpg", item.pubDate, item.title
end