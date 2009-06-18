require 'threepanes'

data=get 'http://www.joyoftech.com/joyoftech/jotblog/index.xml'
rss=RSS::Parser.parse data

rss.items.each do |item|
  n=File.basename item.link, '.html'
  comic "joyoftech/joyimages/#{n}.gif", item.pubDate, item.title
end