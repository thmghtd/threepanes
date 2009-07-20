// Copyright 2009 Max Howell
#import <Cocoa/Cocoa.h>

/** Loads the latest comics using one of the ruby scripts, uses popen, and
  * is mostly asyncronous */
@interface ComicBookGuy:NSObject{
    NSMutableArray* boys;
    NSMutableArray* fetching;
    NSObject* delegate;
}
-(id)initWithDelegate:(id)delegate;
@end


@interface PaperBoy:NSObject{
    NSString* name;
    NSString* identifier;
    FILE* pipe;
    NSURLConnection* http;
    NSMutableData* data;
    
    NSImage* favicon;
    NSString* genre;
    bool enabled;
}
@end