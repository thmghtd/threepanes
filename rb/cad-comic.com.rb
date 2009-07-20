require 'threepanes'

puts "Ctrl-Alt-Del"
puts "Gamer"

comics=Array.new
get_rss 'http://www.cad-comic.com/rss/rss.xml' do |item|
  comics<<item if item.category.content == "Comic"
end

comics.each do |item|
  data=get item.link
  /\?d=(.*)$/=~item.link
  data=~%r{src="/(comics/#{$1.delete'-'}\.jpg)"}
  comic $1,
        item.pubDate,
        item.title.slice(/Comic: (.*)/, 1)
end  