// Copyright 2009 Max Howell

#import <Cocoa/Cocoa.h>


@interface ComicController:NSObject
{
    IBOutlet NSImageView* view;
    NSMutableArray* comics;
}
- (IBAction)next:(id)sender;

@end