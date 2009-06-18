#!/usr/bin/ruby
require 'open-uri'

def isvalid url
  ext=File.extname url
  ['png','jpg','jpeg','gif'].include? ext[1..-1]
end

abort "Usage: #{$0} comic.rb" if ARGV.empty?

IO.popen("ruby -I#{File.dirname __FILE__} #{ARGV[0]}", "r+") do |pipe|
  while url=pipe.gets
    if isvalid url.strip!
      puts "==> #{url}"
      puts "==> #{pipe.gets.strip}"
      puts "==> #{pipe.gets}"
      puts "=============================================================================="
    else
      data=''
      begin
        puts "<== #{url}"
        data=open(url).read
        results=Array.new
        data.scan /([^ ]+\.(jpg|jpeg|png|gif))/i do results<<$1 end
        unless results.empty? #or ARGV.include? '--dumb'
          results.each {|x| puts x}
        end
        puts data if ARGV.include? '--full'
        exit! if ARGV.include? '-1' and not results.empty?
      rescue
        puts "ERR Couldn't load: #{url}"
      end
      pipe.write [data.length].pack("N*")
      pipe.write data
    end
  end
end