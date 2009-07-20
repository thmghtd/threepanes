# Copyright 2009 Max Howell
require 'threepanes'

puts "White Ninja"
puts "Surreal"

get_rss 'http://www.whiteninjacomics.com/rss/z-latest.xml' do |item|
  data=get item.link
  # don't grab the thumbnail version
  data.scan %r[<img src=/(images/comics/(.*?\.gif)) border=0>]i do 
    break unless $2[0..1] == 't-'
  end
  comic $1, item.pubDate, item.title
end