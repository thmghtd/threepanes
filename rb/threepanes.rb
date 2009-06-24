#!/usr/bin/ruby
# Copyright 2009 Max Howell
require 'rss'

if ENV['THREEPANES_DEBUG']
  THREE_PANES_BEGINNING=Time.now
  at_exit { $stdout.flush; $stderr.puts "#{File.basename $0, '.rb'} took #{Time.now-THREE_PANES_BEGINNING} seconds" }
end


def get url
  $stdout.puts url
  $stdout.flush
  n=$stdin.read(4).unpack("N*").first
  data=$stdin.read n
rescue NoMethodError
  nil
end

def comic url, date, title
  if date.nil? or date > Time.now
    $stderr.puts "Invalid time: #{date} for #{url}"
    return;
  end
  
  url='http://example.com/nil.png' if url.nil? or url.empty?
  
  if ['png','jpg','jpeg','gif'].include? File.extname(url).downcase[1..-1]
    
    url="http://#{File.basename $0, '.rb'}/#{url}" if url[0..6] != "http://"

    $stdout.puts url.strip
    $stdout.puts date.to_i
    $stdout.puts title.strip
    $stdout.flush
  else
    $stderr.puts "Unsupported image format: #{url}"
  end
end


if $0 == __FILE__
  abort "Usage: #{$0} comic.rb" if ARGV.empty?

  require 'open-uri'

  def isvalid url
    ext=File.extname url
    ['png','jpg','jpeg','gif'].include? ext[1..-1]
  end
  def ohai s
    puts "\033[0;33;1m==> #{s}\033[0;0m"
  end
  def odeer s
    puts "\033[0;35;1m<== #{s}\033[0;0m"
  end

  IO.popen("ruby -I#{File.dirname __FILE__} #{ARGV[0]}", "r+") do |pipe|
    while url=pipe.gets
      if isvalid url.strip!
        ohai url
        date=pipe.gets.strip
        ohai "#{date} (#{Time.at date.to_i})"
        ohai pipe.gets.strip
      else
        data=''
        begin
          odeer url
          data=open(url).read
          results=Array.new
          data.scan /([^ ]+\.(jpg|jpeg|png|gif))/i do results<<$1 end
          unless results.empty? or ARGV.include? '--dumb'
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
end