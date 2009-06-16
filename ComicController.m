// Copyright 2009 Max Howell
#import "ComicController.h"
#import "NSString+mxcl.h"
#import <stdio.h>


//TODO more Cocoa like if there is such a thing
//TODO check every url looks sane, ie starts with http, or if it doesn't looks
//  reasonable, then prepend the http
NSMutableArray* urlsFromScript( NSString* command )
{
    // 10 is typical, so lets be conservative
    NSMutableArray* urls = [[NSMutableArray alloc] initWithCapacity:10];
    
    FILE* pipe = popen( [command UTF8String], "r" );
    if (!pipe)
        return urls;

    // http://support.microsoft.com/kb/q208427/
    // http://www.boutell.com/newfaq/misc/urllength.html

    char buf[2084];
    while (fgets( buf, 2084, pipe ))
        [urls addObject:[NSURL URLWithString:
                         [[NSString stringWithUTF8String:buf] strip]]];

    pclose( pipe );

    return urls;
}


@implementation ComicController

-(void)awakeFromNib
{
    urls = urlsFromScript( @"ruby ../../xkcd.com.rb" );
   [urls addObjectsFromArray:urlsFromScript( @"ruby ../../explosm.net.rb" )];
}

float titleBarHeight()
{
    NSRect outside = NSMakeRect(0, 0, 100, 100);
    NSRect inside = [NSWindow contentRectForFrameRect:outside
                                            styleMask:NSTitledWindowMask];
    return outside.size.height - inside.size.height;
    
} // titleBarHeight

-(IBAction)next:(id)sender
{
    NSURL* url = [urls lastObject];
    NSImage* image = [[NSImage alloc] initWithContentsOfURL:url];

    if(!image)return; //TODO more
    
   [view setImage:image];
   [urls removeLastObject];

    NSRect frame = [[view window] frame];
    frame.size = [[view image] size];
    frame.size.height += titleBarHeight();
  [[view window] setFrame:frame display:true animate:true];
}

@end
