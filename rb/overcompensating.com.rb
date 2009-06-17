require 'threepanes'

data=get 'http://overcompensating.com/index.xml'
rss=RSS::Parser.parse data

rss.items.each do |item|
  data=get item.link
  data=~%r{src="/(comics/#{File.basename item.link, '.html'}\.png)"}
  comic $1, item.pubDate, item.title
end