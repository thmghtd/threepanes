# Copyright 2009 Max Howell
require 'threepanes'

puts "Amazing Super Powers"
puts "Surreal"

get_rss 'http://www.amazingsuperpowers.com/category/comics/feed' do |item|
  item.description =~ /src="(.*?)"/
  comic $1, item.pubDate, item.title
end