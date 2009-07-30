# Copyright 2009 Max Howell
require 'threepanes'

puts "Piled Higher and Deeper"
puts "Science"

get_rss 'http://www.phdcomics.com/gradfeed.php' do |item|
  item.description =~ /src="(.*?)"/
  comic $1, item.pubDate, item.title
end