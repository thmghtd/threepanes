#
#  xkcd.com.rb
#  Three Panes
#
#  Created by Max Howell on 02/02/2009.
#  Copyright (c) 2009 Last.fm. All rights reserved.
#

require 'rss'
require 'open-uri'

data = '';
open('http://xkcd.com/rss.xml', "User-Agent" => "Ruby/#{RUBY_VERSION}" ) { |f| data = f.read(); }

rss = RSS::Parser.parse( data, false );

rss.items.each do |item|
    puts /src="(.*?)"/.match( item.description )[1]
end