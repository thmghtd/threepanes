// Copyright 2009 Max Howell (created on 02/02/2009)
// Licensed with GPL version 3

#import "WebViewController.h"
#include <stdio.h>


//TODO more Cocoa like if there is such a thing
//TODO check every url looks sane, ie starts with http, or if it doesn't looks reasonable, then prepend the http
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
        [urls addObject:[[NSString alloc] initWithUTF8String:buf]];

    pclose( pipe );

    return urls;
}


@implementation WebViewController

- (void)awakeFromNib
{
    urls = urlsFromScript( @"ruby ../../xkcd.com.rb" );
    [urls addObjectsFromArray:urlsFromScript( @"ruby ../../explosm.net.rb" )];
    [webview setMaintainsBackForwardList:false];
}

- (IBAction)next:(id)sender
{
    [webview setMainFrameURL:[urls lastObject]];
    [urls removeLastObject];
}

@end
