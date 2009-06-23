require 'threepanes'

data=get 'http://www.cad-comic.com/rss/rss.xml'
rss=RSS::Parser.parse data

rss.items.reverse.each do |item|
  if item.category.content == "Comic"
    data=get item.link
    /\?d=(.*)$/=~item.link
    data=~%r{src="/(comics/#{$1.delete'-'}\.jpg)"}
    comic $1, item.pubDate, item.title
  end
end