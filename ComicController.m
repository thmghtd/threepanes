// Copyright 2009 Max Howell
#import "ComicController.h"
#import "ComicBookGuy.h"
#import <stdio.h>

// center the NSImageView in the NSScrollArea
// http://web.mac.com/mabi99/marcocoa/blog/Entries/2008/1/1_Centered_Image_inside_a_Scroll_View.html
@interface NSImageView (mxcl)
@end
@implementation NSImageView (mxcl)
-(void)setFrame:(NSRect)newFrame
{
    if ([_superview isKindOfClass:[NSClipView class]]) {
        NSSize superSize = ((NSClipView*)_superview).frame.size;
        NSSize imageSize = ((NSImage*)[self image]).size;
        
        newFrame.size.width = MAX(imageSize.width, superSize.width);
        newFrame.size.height = MAX(imageSize.height, superSize.height);
    }
    [super setFrame:newFrame];
}
/** pin content as expected, not bottom-left! */
-(bool)isFlipped
{
    return true;
}
@end


@implementation ComicController

-(void)awakeFromNib
{
    comics = [[NSMutableArray alloc] initWithCapacity:3];
    [spinner startAnimation:self];
    [scrollview setHasHorizontalScroller:false];    
    [[ComicBookGuy alloc] performSelector:@selector(initWithDelegate:) 
                               withObject:self
                               afterDelay:0];
}

NSInteger sort(id a, id b, void* v)
{
    return [[b objectForKey:@"UTC"] compare:[a objectForKey:@"UTC"]];
}

-(void)updateDockBadge
{
    uint n = [comics count];
    [[NSApp dockTile] setBadgeLabel:n ? [NSString stringWithFormat: @"%d", n]
                                      : @""];
}

-(void)delivery:(NSDictionary*)comic
{
    // newest comics at the end
    time_t time = [[comic objectForKey:@"UTC"] unsignedIntValue];
    for (int x=0; x<[comics count]; ++x)
        if(time > [[[comics objectAtIndex:x] objectForKey:@"UTC"] unsignedIntValue]){
            [comics insertObject:comic atIndex:x];
            goto woot;
        }
    [comics addObject:comic];
woot:
    [self updateDockBadge];
    
    if([view image] == nil){
        [self next:self];
        [spinner stopAnimation:self];
    }
}

-(void)deliveriesComplete
{
    if([view image] == nil){
        [spinner stopAnimation:self];
        [noComicsLabel setHidden:false];
    }
}

float titleBarHeight()
{
    NSRect outside = NSMakeRect(0, 0, 100, 100);
    NSRect inside = [NSWindow contentRectForFrameRect:outside
                                            styleMask:NSTitledWindowMask];
    return outside.size.height - inside.size.height;
}

-(NSSize)idealWindowSize
{    
    NSSize size = [[view image] size];
    size.height += titleBarHeight();
    if(size.height > [[[view window] screen] visibleFrame].size.height) 
        size.width += [NSScroller scrollerWidth];
    return size;
}

-(IBAction)next:(id)sender
{
    if([comics count] == 0) //TODO disable Next action
        return;
    
    @try{
        NSDictionary* comic = [comics lastObject];

        NSURL* url = [comic objectForKey:@"URL"];
        NSLog(@"%@",url);
        
        NSImageRep* rep = [NSImageRep imageRepWithContentsOfURL:url];
        
        if(rep){
            // some comics (eg cad-comic) save their images with a stupid DPI
            // settings (ie. 180dpi of all things), and NSImage blindly obeys, so
            // we have to override it with this convuluted method           
            NSImage* image = [[[NSImage alloc] init] autorelease];
            [image addRepresentation:rep];
            [image setSize:NSMakeSize([rep pixelsWide], [rep pixelsHigh])];
            
            [view setImage:image];
          	[view setFrameSize:[image size]];
            
            NSRect frame = [[view window] frame];
            frame.size = [self idealWindowSize];
            [[view window] setFrame:frame display:true animate:true];            
            [[view window] setTitle:[comic objectForKey:@"Title"]];

            [[NSUserDefaults standardUserDefaults] setObject:[comic objectForKey:@"UTC"]
                                                      forKey:[comic objectForKey:@"Comic"]];
        }else{
            NSLog(@"Load failure for %@", [comic objectForKey:@"Comic"]);
            [self next:self];
            //TODO
        }
    }@catch (NSException*e){
        //TODO
    }
    [comics removeLastObject];
    [self updateDockBadge];
}

-(NSRect)windowWillUseStandardFrame:(NSWindow*)window defaultFrame:(NSRect)frame
{
    frame.size = [self idealWindowSize];
    return frame;
}

@end