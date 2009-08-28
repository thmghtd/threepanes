require 'threepanes'

puts "Penny Arcade"
puts "Gamer"

get_rss 'http://feeds.penny-arcade.com/pa-mainsite' do |item|
  next unless /^New Comic\s*:/ =~ item.description
  year=item.pubDate.year
  month=item.pubDate.month.to_s.rjust 2, '0'
  day=item.pubDate.mday.to_s.rjust 2, '0'
  comic "http://www.penny-arcade.com/images/#{year}/#{year}#{month}#{day}.jpg", item.pubDate, item.title
end