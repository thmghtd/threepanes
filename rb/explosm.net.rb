# Copyright 2009 Max Howell on 02/02/2009.
require 'threepanes'

data=get 'http://feeds.feedburner.com/Explosm'
rss=RSS::Parser.parse data, false

comics=Array.new
rss.items.reverse.each do |item|
  comics<<item if item.category.to_s == "<category>Comics</category>"
end

comics.last(5).each do |item|
  get(item.link)=~%r[src="(http://www.explosm.net/db/files/Comics/.*?)"]
  comic $1, item.pubDate, item.title
end