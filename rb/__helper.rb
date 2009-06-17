#!/usr/bin/ruby
require 'open-uri'

def isvalid url
  ext=File.extname url
  ['png','jpg','jpeg','gif'].include? ext[1..-1]
end

abort "Usage: #{$0} comic.rb" if ARGV.empty?

IO.popen("ruby -I. #{ARGV[0]}", "r+") do |pipe|
  while url=pipe.gets
    if isvalid url.strip!
      puts "Script says: #{url}, #{pipe.gets.strip}, #{pipe.gets}"
      puts
    else
      puts "Fetching: #{url}"
      data=open(url).read
      puts "=============================================================================="
      data.scan /src="\/(.*?\.(jpg|jpeg|png|gif))"/ do |x|
        puts $1
      end
      puts "=============================================================================="
      pipe.write [data.length].pack("N*")
      pipe.write data
    end
  end
end