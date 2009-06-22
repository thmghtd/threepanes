// Copyright 2009 Max Howell

#import <Cocoa/Cocoa.h>


@interface ComicController:NSObject
{
    IBOutlet NSImageView* view;
    IBOutlet NSProgressIndicator* spinner;
    IBOutlet NSTextField* noComicsLabel;
    IBOutlet NSScrollView* scrollview;

    NSMutableArray* comics;
    NSURLConnection* http;
}
- (IBAction)next:(id)sender;
@end