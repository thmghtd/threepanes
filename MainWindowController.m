// Copyright 2009 Max Howell
#import "MainWindowController.h"
#import "PaperBoy.h"
#import "ImageViewController.h"
#import "comic.h"
#import <stdio.h>


@implementation MainWindowController

-(void)awakeFromNib
{
    all_comics_loaded = false;
    idealframe = [window frame];
    [guy performSelector:@selector(initWithDelegate:) 
              withObject:self
              afterDelay:0];
    [spinner startAnimation:self];
    [self performSelector:@selector(windowDidMove:) withObject:nil];
    [scrollview setVerticalLineScroll:70];
    [window center];
}

-(void)delivery:(Comic*)comic
{
    [next setEnabled:true];    
    [comcon addComic:comic];
}

-(void)deliveriesComplete
{
    NSLog(@"Deliveries complete!");
    
    all_comics_loaded = true;

    //TODO count can be 0 currently even though an image is showing :(
    if(comcon.count == 0 && view.image == nil)
        [self allDone];
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

-(void)onComicCountChanged:(NSNumber*)count
{
	uint n = [count unsignedIntValue];
    [[NSApp dockTile] setBadgeLabel:n ? [NSString stringWithFormat: @"%d", n] : @""];
}

-(void)onComicFailure:(Comic*)comic type:(int)failure_type
{
    NSLog(@"[UI] %@ failed", comic.url);
}

-(void)onComicChanged:(Comic*)comic
{
    if(comic){
        [spinner stopAnimation:self];
        [window setTitle:comic.title];

        //TODO center in screen, or center about its current position
        idealframe = [self idealFrameForComicOfSize:comic.size];

        [scrollview setHasVerticalScroller:show_scroller];
        id cv = [scrollview contentView];
        [cv scrollToPoint:NSMakePoint(0,0)];
        [scrollview reflectScrolledClipView:cv];
        [window setFrame:idealframe display:true animate:true];
    }else if(all_comics_loaded)
        [self allDone];
    else{
        // if we haven't finished loading then there is a chance a new comic
        // will still arrive, if not we handle that elsewhere
        [spinner startAnimation:self];
		NSLog(@"[UI] Waiting for PaperBoy to deliver next comic");
    }
    
    //TODO set next action disabled if no comics left
}

-(void)allDone
{
    NSRect rect = [self idealFrameForComicOfSize:NSMakeSize(480,360)];
    
    [spinner stopAnimation:self];
    [next setEnabled:false];
    [label setHidden:true];
    [view setImage:[NSImage imageNamed:@"Balloon"]];
    [scrollview setHasVerticalScroller:false];
    [window setTitle:@"Three Panes"];
    [window setFrame:rect display:true animate:true];
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


@interface NSScrollView (mxcl)
@end
@implementation NSScrollView (mxcl)

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(BOOL)becomeFirstResponder
{
    return YES;
}

-(BOOL)resignFirstResponder
{
    return YES;
}

#define SCROLL_MACRO(OPERATOR) \
    NSView *dv = [self documentView]; \
    NSPoint point = [dv visibleRect].origin; \
    point.y OPERATOR [self verticalLineScroll]; \
    [dv scrollPoint:point];

//FIXME it seems insane that I have to implement these myself!
-(void)scrollLineUp:(id)sender
{
    SCROLL_MACRO(-=)
}
-(void)scrollLineDown:(id)sender
{
    SCROLL_MACRO(+=)
}

-(void)keyDown:(NSEvent*)event
{
    unichar c = [[event characters] characterAtIndex:0];

    switch(c){
        case NSUpArrowFunctionKey:
            [self scrollLineUp:nil];
            break;
        case NSDownArrowFunctionKey:
            [self scrollLineDown:nil];
            break;
        case 0x0020: // space key
            [self pageDown:nil];
            break;
        default:
            [super keyDown:event];
            break;
    }
}
@end
