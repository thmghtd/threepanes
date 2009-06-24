// Copyright 2009 Max Howell
#import <Cocoa/Cocoa.h>

@interface ImageViewController:NSObject{
    NSPointerArray* comics;
    NSURLConnection* http;
    NSMutableData* data;
    comic_t* active;
    IBOutlet id delegate;
    IBOutlet NSImageView* view;
    
    bool dodelegate;
    bool waiting_for_next;
}

-(bool)next;
-(void)addComic:(comic_t*)comic;
-(NSUInteger)count;

@end
