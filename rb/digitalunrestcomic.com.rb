# Copyright 2009 Max Howell
require 'threepanes'

puts "Digital Unrest"
puts "Gamer"

get('http://www.digitalunrestcomic.com/archive.php').scan /index\.php\?date=((\d\d\d\d)-(\d\d)-(\d\d))/ do
  time=Time.mktime $2, $3, $4, 0, 0, 0, 0
  comic "http://www.digitalunrestcomic.com/strips/#{$1}.jpg",
        time,
        $1 if time > $previous
end
