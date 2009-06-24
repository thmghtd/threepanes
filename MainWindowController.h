// Copyright 2009 Max Howell
#import <Cocoa/Cocoa.h>
@class ImageViewController;


@interface MainWindowController:NSObject
{
    IBOutlet NSProgressIndicator* spinner;
    IBOutlet NSTextField* label;
    IBOutlet NSWindow* window;
    IBOutlet NSScrollView* scrollview;
    IBOutlet ImageViewController* comcon;
    IBOutlet NSImageView* view;
    
    NSRect idealframe;  
    NSPoint anchor; /** the main window centers about this */
    bool all_comics_loaded;
}

-(void)onComicChanged:(comic_t*)comic;
-(IBAction)next:(id)sender;

@end