require 'threepanes'

data=get 'http://overcompensating.com/index.xml'
rss=RSS::Parser.parse data, false

rss.items.reverse.last(3).each do |item|
  data=get item.link
  data=~%r{src="/(comics/#{File.basename item.link, '.html'}\.(png|gif))"}
  comic $1, item.pubDate, item.title
end