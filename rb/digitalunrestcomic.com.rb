# Copyright 2009 Max Howell
require 'threepanes'

data=get 'http://www.rsspect.com/rss/digitalunrest.xml'
rss=RSS::Parser.parse data, false

rss.items.each do |item|
  year=item.pubDate.year
  month=item.pubDate.month.to_s.rjust 2, '0'
  day=item.pubDate.mday.to_s.rjust 2, '0'
  comic "http://www.digitalunrestcomic.com/strips/#{year}-#{month}-#{day}.jpg", 
        item.pubDate,
        item.title.gsub(/<\/?b>/, '')
end