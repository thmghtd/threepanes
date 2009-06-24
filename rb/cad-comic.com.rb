require 'threepanes'

data=get 'http://www.cad-comic.com/rss/rss.xml'
rss=RSS::Parser.parse data, false

comics=Array.new
rss.items.reverse.each do |item|
  comics<<item if item.category.content == "Comic"
end

comics.last(3).each do |item|
  data=get item.link
  /\?d=(.*)$/=~item.link
  data=~%r{src="/(comics/#{$1.delete'-'}\.jpg)"}
  comic $1,
        item.pubDate,
        item.title.slice(/Comic: (.*)/, 1)
end  