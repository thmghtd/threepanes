// Copyright 2009 Max Howell
#import <Cocoa/Cocoa.h>

/* The image view controller shows the latest comic.
 * It also has a next action that loads the next comic and reports to a delegate
 * when that comic is being displayed.
 * It also updates the persistent store to reflect which comics have been viewed
 * by the user
 */

@interface ImageViewController:NSObject{
    NSURLConnection* http;
    NSMutableData* data;
    IBOutlet id delegate;
    IBOutlet NSImageView* view;
    
    bool set_comic_when_loaded;

    NSMutableArray* comics;
    Comic* loading;
}

-(bool)next;
-(void)addComic:(Comic*)comic;
-(NSUInteger)count;

@end
