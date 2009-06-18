# Copyright 2009 Max Howell
require 'threepanes'

data=get 'http://www.boredandevil.com/rss.xml'
# the xml doesn't parse!
data.gsub! /<description>.*?<\/description>/mi, '<description></description>'
# AND the RSS is invalid!
data.gsub! /pubdate/, 'pubDate'
rss=RSS::Parser.parse data, false

rss.items.each do |item|
  year=item.pubDate.year
  month=item.pubDate.month.to_s.rjust 2, '0'
  day=item.pubDate.mday.to_s.rjust 2, '0'    
  comic "http://www.boredandevil.com/strips/#{year}-#{month}-#{day}.gif",
        item.pubDate,
        item.title
end