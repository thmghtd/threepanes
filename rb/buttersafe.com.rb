# Copyright 2009 Max Howell
require 'threepanes'

data=get 'http://feeds.feedburner.com/Buttersafe'
rss=RSS::Parser.parse data, false

rss.items.reverse.each do |item|
  get(item.link) =~ %r[src='((http://(www\.)?buttersafe.com)?/comics/\d\d\d\d-\d\d-\d\d-.*?\.jpg)']
  comic $1, item.pubDate, item.title
end