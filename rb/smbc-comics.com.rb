require 'threepanes'

data=get 'http://www.smbc-comics.com/rss.php'
rss=RSS::Parser.parse data, false

rss.items.reverse.each do |item|
  item.description =~ %r[src="(http://(www.)?smbc-comics.com/comics/\d\d\d\d\d\d\d\d.gif)"]
  comic $1, item.pubDate, item.title
end