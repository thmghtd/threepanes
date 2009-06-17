# Copyright 2009 Max Howell
require 'rss'

THREE_PANES_BEGINNING=Time.now
at_exit { $stdout.flush; $stderr.puts "#{File.basename $0, '.rb'} took #{Time.now-THREE_PANES_BEGINNING} seconds" }

def get url
  $stdout.puts url
  $stdout.flush
  n=$stdin.read(4).unpack("N*").first
  data=$stdin.read n
end

def comic url, date, title
  if ['png','jpg','jpeg','gif'].include? File.extname(url).downcase[1..-1]
    
    url="http://#{File.basename $0, '.rb'}/#{url}" if url[0..6] != "http://"

    $stdout.puts url
    $stdout.puts date.to_i
    $stdout.puts title
    $stdout.flush
  else
    $stderr.puts 'Unsupported image format'
  end
end
