# Copyright 2009 Max Howell
require 'threepanes'

puts "Questionable Content"
puts "Sitcom"

get_rss 'http://www.questionablecontent.net/QCRSS.xml' do |item|
  item.description =~ /src="(.*?)"/
  comic $1, item.pubDate, item.title
end