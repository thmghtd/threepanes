require 'threepanes'

puts "Subnormality!"
puts "Satire"

get_rss 'http://www.viruscomix.com/rss.xml' do |item|
  get(item.link) =~ /="([^"]+?\.jpg)"/
  comic $1, item.pubDate, item.title
end