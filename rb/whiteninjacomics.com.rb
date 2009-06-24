# Copyright 2009 Max Howell
require 'threepanes'

data=get 'http://www.whiteninjacomics.com/rss/z-latest.xml'
rss=RSS::Parser.parse data, false

rss.items.reverse.last(3).each do |item|
  data=get item.link
  # don't grab the thumbnail version
  data.scan %r[<img src=/(images/comics/(.*?\.gif)) border=0>]i do 
    break unless $2[0..1] == 't-'
  end
  comic $1, item.pubDate, item.title
end