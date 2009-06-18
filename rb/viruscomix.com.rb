require 'threepanes'

data=get 'http://www.viruscomix.com/rss.xml'
rss=RSS::Parser.parse data, false

rss.items.each do |item|
  get(item.link) =~ /="([^"]+?\.jpg)"/
  comic $1, item.pubDate, item.title
end