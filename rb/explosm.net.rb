# Copyright 2009 Max Howell on 02/02/2009.
require 'threepanes'

puts "Cyanide and Happiness"
puts "Surreal"

get_rss 'http://feeds.feedburner.com/Explosm' do |item|
  next if item.category.to_s != "<category>Comics</category>"
  get(item.link)=~%r[src="(http://www.explosm.net/db/files/Comics/.*?)"]
  comic $1, item.pubDate, item.title
end