# Copyright 2009 Max Howell
require 'threepanes'

data=get 'http://fanboys-online.com/rss/comic.xml'
rss=RSS::Parser.parse data, false

rss.items.reverse.each do |item|
  item.description =~ %r[src="http://fanboys-online.com/thumbs/(\d\d\d\d\d\d\d\d\.jpg)"]
  comic "comics/#{$1}", item.pubDate, item.title
end