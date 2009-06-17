# Copyright 2009 Max Howell
require 'threepanes'

data=get('http://xkcd.com/rss.xml')
rss=RSS::Parser.parse data

rss.items.each do |item|
  item.description =~ /src="(.*?)"/
  comic $1, item.pubDate, item.title
end