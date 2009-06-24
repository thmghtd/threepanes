# Copyright 2009 Max Howell
require 'threepanes'

data=get "http://www.boredandevil.com/year.php?year=#{Time.now.year}"
# the xml doesn't parse!
data.gsub! /<description>.*?<\/description>/mi, '<description></description>'
# AND the RSS is invalid!
data.gsub! /pubdate/, 'pubDate'

dates=Array.new
data.scan /href="archive.php\?date=(\d\d\d\d-\d\d-\d\d)"/ do
  dates<<$1
end
dates.each do |date|
  comic "http://www.boredandevil.com/strips/#{date}.gif",
        Time.parse(date),
        date
end