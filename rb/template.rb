# Writing a Three Panes Comic Script
# ==================================
# Below is a sample that you can adapt.
#
# Save a copy of this file to "Three Panes.app/Contents/Resources/rb/" (this
# file is read-only in the hope this will prevent accidental overwrites). You
# must name the file after the domain, eg. xkcd.com.rb
#
# The threepanes.rb script is designed to help you develop your script by
# downloading the RSS and HTML files and parsing them for likely looking 
# image URLS:
#
#    ./threepanes foo.rb [--full] [--dumb] [-1]
#
# --full  Shows the contents of all downloaded files
# --dumb  Makes the script stupid, it won't try to help you. Thus it only 
#         outputs minimal information (ie. it is less verbose).
#  -1     Stops after one download, which is usually the RSS feed, so use with
#         the --full switch
#
# Finally when everything is working, restart Three Panes to test it for real.


require 'threepanes'

puts "xkcd" # the pretty title of the webcomic
puts "Geek" # pick whatever genre suits it, we'll group them as we go

# don't parse the RSS yourself, we do some magic
get_rss 'http://xkcd.com/rss.xml' do |item|
  item.description =~ /src="(.*?)"/
  comic $1, item.pubDate, item.title
end


# Implementation Tips
# ===================
# It is very common for the feed to not specify the comic image url
# There are several options, I suggest you look at the other bundled scripts 
# but briefly:
#
#   1. The comic image url may be based on the date, or the comic page url
#   2. You can scrape the comic page, use the get function to get it
#
# Option 2 sucks, because it takes ages, so if you must do that, do it 
# minimally, use the $previous global variable to determine which comics
# Three Panes needs and only return comics newer than that time.
#
# If there isn't a good RSS feed, look for the site's archive page and parse
# that.
#
#
# Technical Rationale
# ===================
# The reason that http downloads are delegated back to Three Panes is so that
# the system wide HTTP cache is used. Thus we rape RSS feeds less.
#
# The script communicates back to Three Panes using a stdin/stdout pipe. So
# don't puts, use $stderr.puts instead if you want to see debug output.
#
# -- Max Howell <http://twitter.com/mxcl>