// Copyright 2009 Max Howell
#import "MainWindowController.h"
#import "ComicBookGuy.h"
#import "ImageViewController.h"
#import "comic.h"
#import <stdio.h>


@implementation MainWindowController

-(void)awakeFromNib
{
    all_comics_loaded = false;
    idealframe = [window frame];
    [[ComicBookGuy alloc] performSelector:@selector(initWithDelegate:) 
                               withObject:self
                               afterDelay:0];
    [spinner startAnimation:self];
    [self performSelector:@selector(windowDidMove:) withObject:nil];
    [window center];
}

-(void)updateDockBadge
{
    uint n = [comcon count];
    [[NSApp dockTile] setBadgeLabel:n ? [NSString stringWithFormat: @"%d", n]
                                      : @""];
}

-(void)delivery:(comic_t*)comic
{
    [label setStringValue:@"No more comics today :("];    
    //TODO disable next action until now!
    [comcon addComic:comic];
    [self updateDockBadge];
}

-(void)deliveriesComplete
{
    all_comics_loaded = true;

    //TODO count can be 0 currently even though an image is showing :(
    if([comcon count] == 0 && [view image] == nil){
        [spinner stopAnimation:self];
        [label setHidden:false];
        [view setHidden:true];
    }
}

-(IBAction)next:(id)sender
{
    if([comcon next])
        [spinner startAnimation:self];
}

static inline float titleBarHeight()
{
    NSRect outside = NSMakeRect(0, 0, 100, 100);
    NSRect inside = [NSWindow contentRectForFrameRect:outside
                                            styleMask:NSTitledWindowMask];
    return outside.size.height - inside.size.height;
}

static bool show_scroller = false;
-(NSRect)idealFrameForComicOfSize:(NSSize)size
{
    size.height += titleBarHeight();
    NSRect vf = [[window screen] visibleFrame];
    uint const vh = vf.size.height;
    if(size.height > vh){
        show_scroller = true;
        size.width += [NSScroller scrollerWidth];
        size.height = vh;
    }else
        show_scroller = false;
        
    NSRect r;
    r.size = size;
    r.origin = anchor;
    r.origin.x -= (int)(size.width/2);
    r.origin.y -= (int)((2*size.height)/3);
    
    uint const vy = vf.origin.y;
    if(r.origin.y < vy)
        r.origin.y = vy;
    
    return r;
}

-(void)onComicChanged:(comic_t*)comic
{
    NSLog(@"Comic changed to: %@", comic ? comic->url : nil);
    
    [spinner stopAnimation:self];
    
    if(comic){
        [window setTitle:comic->title];

        //TODO center in screen, or center about its current position
        idealframe = [self idealFrameForComicOfSize:comic->size];

        [scrollview setHasVerticalScroller:show_scroller];
        id cv = [scrollview contentView];
        [cv scrollToPoint:NSMakePoint(0,0)];
        [scrollview reflectScrolledClipView:cv];
        [window setFrame:idealframe display:true animate:true];

        [self updateDockBadge];
    }else if(all_comics_loaded){
        [view setHidden:true];
        [label setHidden:false];
        [window setTitle:@"Three Panes"];
    }else{
        // if we haven't finished loading then there is a chance a new comic
        // will still arrive, if not we handle that elsewhere
        [spinner startAnimation:self];
    }
    
    //TODO set next action disabled if no comics left
}

-(void)windowDidMove:(NSNotification*)notification
{
    // all ints or window manager clamps us to nearest pixel and increases the
    // width giving off by one errors
    NSRect f = [window frame];
    f.origin.x += (int)(f.size.width/2);
    f.origin.y += (int)((2*f.size.height)/3);
    anchor = f.origin;
}

-(BOOL)applicationShouldHandleReopen:(NSApplication*)app hasVisibleWindows:(BOOL)flag
{
    [window makeKeyAndOrderFront:self];
    return YES;
}

@end