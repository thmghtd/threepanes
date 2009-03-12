#
#  explosm.net.rb
#  Three Panes
#
#  Created by Max Howell on 02/02/2009.
#  Copyright (c) 2009 Last.fm. All rights reserved.
#

require 'rss'
require 'open-uri'

require 'net/http'

data = '';
open('http://feeds.feedburner.com/Explosm', "User-Agent" => "Ruby/#{RUBY_VERSION}") { |f| data = f.read() }

rss = RSS::Parser.parse( data, false );

rss.items.each do |item|
  puts %r{src="(http://www.explosm.net/db/files/Comics/.*?)"}.match( open( item.link ).read() )[1]
end
