# Copyright 2009 Max Howell
require 'threepanes'

puts "Bored and Evil"
puts "Sitcom"

data=get "http://www.boredandevil.com/year.php?year=#{Time.now.year}"

data.scan /href="archive\.php\?date=((\d\d\d\d)-(\d\d)-(\d\d))"/ do
  time=Time.mktime $2, $3, $4, 0, 0, 0, 0
  $stderr.puts time
  comic "http://www.boredandevil.com/strips/#{$1}.gif",
        time,
        $1 if time > $previous
end