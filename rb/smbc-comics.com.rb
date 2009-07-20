require 'threepanes'

puts "Saturday Morning Breakfast Cereal"
puts "Bizarre"

get_rss 'http://www.smbc-comics.com/rss.php' do |item|
  item.description =~ %r[src="(http://(www.)?smbc-comics.com/comics/\d\d\d\d\d\d\d\d.gif)"]
  comic $1, item.pubDate, item.title
end