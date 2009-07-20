require 'threepanes'

puts "Joy of Tech"
puts "Geek"

get_rss 'http://www.joyoftech.com/joyoftech/jotblog/index.xml' do |item|
  n=File.basename item.link, '.html'
  comic "joyoftech/joyimages/#{n}.jpg", item.pubDate, item.title
end