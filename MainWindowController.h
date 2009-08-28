// Copyright 2009 Max Howell
#import <Cocoa/Cocoa.h>
@class ImageViewController;
@class PaperBoy;


@interface MainWindowController:NSObject
{
    IBOutlet NSProgressIndicator* spinner;
    IBOutlet NSTextField* label;
    IBOutlet NSWindow* window;
    IBOutlet NSScrollView* scrollview;
    IBOutlet ImageViewController* comcon;
    IBOutlet NSImageView* view;
    IBOutlet NSMenuItem* prev;
    IBOutlet NSMenuItem* next;
    IBOutlet PaperBoy* guy;
    
    NSRect idealframe;
    NSPoint anchor; /** the main window centers about this */
    bool all_comics_loaded;
}

-(void)onComicChanged:(Comic*)comic;
-(IBAction)next:(id)sender;
-(void)allDone;

@end
