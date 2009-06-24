# Copyright 2009 Max Howell
require 'threepanes'

data=get 'http://www.questionablecontent.net/QCRSS.xml'
rss=RSS::Parser.parse data, false

rss.items.reverse.last(5).each do |item|
  item.description =~ /src="(.*?)"/
  comic $1, item.pubDate, item.title
end