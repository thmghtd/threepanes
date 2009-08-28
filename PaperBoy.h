// Copyright 2009 Max Howell
#import <Cocoa/Cocoa.h>

/** Delivers new comics to the delegate */
@interface PaperBoy:NSObject{
    NSMutableArray* houses;
    NSMutableArray* fetching;
    NSObject* delegate;
	NSMutableArray* scripts;
	
    IBOutlet NSTableView* tableview;
}
-(id)initWithDelegate:(id)delegate;
@end


/* There's a publishing house for each comic */
@interface PublishingHouse:NSObject{
    NSString* name;
    NSString* identifier;
    FILE* pipe;
    NSURLConnection* http;
    NSMutableData* data;
    
    NSImage* favicon;
    NSString* genre;
    bool enabled;
}

@property (nonatomic, assign) NSURLConnection* http;
@property (nonatomic, readonly) NSString* identifier;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly, assign) FILE* pipe;
@property (nonatomic, readonly) NSMutableData* data;

@end