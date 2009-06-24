# Copyright 2009 Max Howell
require 'threepanes'

data=get 'http://www.dieselsweeties.com/ds-unifeed.xml'
rss=RSS::Parser.parse data, false

rss.items.reverse.each do |item|
  item.description =~ %r[src="(http://(www.)?dieselsweeties.com/strips/.*?)"]
  comic $1, item.pubDate, item.title if $1
end