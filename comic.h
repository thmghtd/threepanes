// Copyright 2009 Max Howell
#import <Cocoa/Cocoa.h>

@interface Comic:NSObject
{
    NSImageRep* image;
    NSString* title;
    time_t utc;
    NSURL* url;
    NSString* ident;
    NSSize size;
};

@property (nonatomic, retain) NSImageRep* image;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, assign) time_t utc;
@property (nonatomic, retain) NSURL* url;
@property (nonatomic, retain) NSString* ident;
@property (nonatomic, assign) NSSize size;

@end
