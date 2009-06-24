// Copyright 2009 Max Howell
#import <Cocoa/Cocoa.h>

struct comic
{
    NSImageRep* image;
    NSString* title;
    time_t utc;
    NSURL* url;
    NSURL* www;
    NSString* ident;
    NSSize size;
};