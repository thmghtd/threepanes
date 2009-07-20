require 'threepanes'

puts "Overcompensating"
puts "Sitcom"

get_rss 'http://overcompensating.com/index.xml' do |item|
  data=get item.link
  data=~%r{src="/(comics/#{File.basename item.link, '.html'}\.(png|gif))"}
  comic $1, item.pubDate, item.title
end