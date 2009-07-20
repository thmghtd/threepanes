# Copyright 2009 Max Howell
require 'threepanes'

puts "Dueling Analogs"
puts "Gamer"

get_rss 'http://www.duelinganalogs.com/rss.php' do |item|
  next unless item.category.to_s.include? 'comic'
  %r{(http://www.duelinganalogs.com/comics/\d\d\d\d-\d\d-\d\d.(jpg|png))} =~ item.description
  comic $1, item.pubDate, item.title
end