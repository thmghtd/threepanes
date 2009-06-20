// Copyright 2009 Max Howell
#import "ComicController.h"
#import "ComicBookGuy.h"
#import <stdio.h>

@implementation ComicController

-(void)awakeFromNib
{
    comics = [[NSMutableArray alloc] initWithCapacity:3];
    [[ComicBookGuy alloc] initWithDelegate:self];
}

NSInteger sort(id a, id b, void* v)
{
    return [[b objectForKey:@"UTC"] compare:[a objectForKey:@"UTC"]];
}

-(void)updateDockBadge
{
    uint n = [comics count];
    NSDockTile* tile = [NSApp dockTile];
    if(n){
        [tile setBadgeLabel:[NSString stringWithFormat: @"%d", n]];
    }else
        [tile setBadgeLabel:@""];
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
}

float titleBarHeight()
{
    NSRect outside = NSMakeRect(0, 0, 100, 100);
    NSRect inside = [NSWindow contentRectForFrameRect:outside
                                            styleMask:NSTitledWindowMask];
    return outside.size.height - inside.size.height;
}

-(IBAction)next:(id)sender
{
    @try{
        NSDictionary* comic = [comics lastObject];

        NSURL* url = [comic objectForKey:@"URL"];
        NSLog(@"%@",url);
        NSImage* image = [[NSImage alloc] initWithContentsOfURL:url];
        
        if(image){
            [view setImage:image];

            NSRect frame = [[view window] frame];
            frame.size = [[view image] size];
            frame.size.height += titleBarHeight();
            [[view window] setFrame:frame display:true animate:true];

            [[view window] setTitle:[comic objectForKey:@"Title"]];

            [[NSUserDefaults standardUserDefaults] setObject:[comic objectForKey:@"UTC"]
                                                      forKey:[comic objectForKey:@"Comic"]];
        }else{
            //TODO
        }
    }@catch (NSException*e){
        //TODO
    }
    [comics removeLastObject];
    [self updateDockBadge];
}

@end