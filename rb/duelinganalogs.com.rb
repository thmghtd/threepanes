# Copyright 2009 Max Howell
require 'threepanes'

data=get 'http://www.duelinganalogs.com/rss.php'
rss=RSS::Parser.parse data, false

rss.items.each do |item|
  next unless item.category.to_s.include? 'comic'
  %r{(http://www.duelinganalogs.com/comics/\d\d\d\d-\d\d-\d\d.png)} =~ item.description
  comic $1, item.pubDate, item.title
end