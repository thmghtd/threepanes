require 'threepanes'

data=get 'http://www.orneryboy.com/rssfeed.php'
rss=RSS::Parser.parse data, false

rss.items.reverse.each do |item|
  item.link =~ %r{comicID=(\d+)}
  comic "http://www.orneryboy.com/comics/#{$1.rjust 8, '0'}.swf", item.pubDate, item.title
end