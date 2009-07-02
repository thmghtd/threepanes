# Copyright 2009 Max Howell
require 'threepanes'

data=get 'http://www.chainsawsuit.com/feed.xml'
rss=RSS::Parser.parse data, false

rss.items.reverse.each do |item|
  item.description =~ /src="(.*?)"/
  comic $1, item.pubDate, item.title
end