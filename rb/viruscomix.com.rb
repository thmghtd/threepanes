require 'threepanes'

data=get 'http://www.viruscomix.com/rss.xml'
rss=RSS::Parser.parse data, false

item=rss.items.first
get(item.link) =~ /="([^"]+?\.jpg)"/
comic $1, item.pubDate, item.title