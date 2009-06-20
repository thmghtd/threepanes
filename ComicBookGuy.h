// Copyright 2009 Max Howell
#import <Cocoa/Cocoa.h>

/** Loads the latest comics using one of the ruby scripts, uses popen, and
  * is mostly asyncronous */
@interface ComicBookGuy:NSObject{
    NSMutableArray* boys;
    NSMutableArray* comics;
    NSObject* delegate;
}
-(id)initWithDelegate:(NSObject*)delegate;
-(NSMutableArray*)comics;
@end


@interface PaperBoy:NSObject{
    NSString* name;
    FILE* pipe;
    NSURLConnection* http;
    NSMutableData* data;
}

@end