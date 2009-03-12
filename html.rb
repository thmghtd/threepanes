#
#  Created by Max Howell on 02/02/2009.
#  Copyright (c) 2009 Last.fm. All rights reserved.
#
# FIXME hash collision is possible
#

require 'rss'
require 'open-uri'

items = Hash.new

def get( url )
  open( url, "User-Agent" => "Ruby/#{RUBY_VERSION}" ).read
end

def get_rss( url )
  RSS::Parser.parse( get( url ), false ).items
end

#
#  xkcd.com
#

get_rss('http://xkcd.com/rss.xml').each do |item|
  puts item.date
  items[item.date] = item.description
end

#
#  explosm.net.rb
#

get_rss('http://feeds.feedburner.com/Explosm').each do |item|
  puts item.date
  %r{src="(http://www.explosm.net/db/files/Comics/.*?)"} =~ get( item.link )
  items[item.date] = "<img src='#{$1}'><br>"
end

#
#  cad-comic.com
#

get_rss('http://www.cad-comic.com/rss/rss.xml').each do |item|
  next if item.category.content != "Comic"
  
  puts item.date
    
  /\?d=(.*)$/ =~ item.link
  date = $1.delete( '-' )
  %r{src="/(comics/#{date}.jpg)"} =~ get( item.link )
  items[item.date] = "<img src='http://www.cad-comic.com/#{$1}'><br>"
end

#
#  OverCompensating.com
#

get_rss('http://overcompensating.com/index.xml').each do |item|
  puts item.date
  items[item.date] = item.description
end

#
#  puts
#

exit

puts '<html><body>'
items.sort.each do |date, html|
  puts html
end
puts '</body></html>'
