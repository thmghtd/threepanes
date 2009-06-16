// Copyright 2009 Max Howell

#import <Cocoa/Cocoa.h>


@interface ComicController:NSObject
{
    IBOutlet NSImageView* view;
    NSMutableArray* urls;
}
- (IBAction)next:(id)sender;

@end