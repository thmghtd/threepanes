// Copyright 2009 Max Howell
#import "ComicController.h"
#import "NSString+mxcl.h"
#import <stdio.h>


static NSString* fgetns(FILE* f)
{
    // http://support.microsoft.com/kb/q208427/
    // http://www.boutell.com/newfaq/misc/urllength.html
    char buf[2084];
    if(!fgets(buf, 2084, f))return nil;
    return [[NSString stringWithUTF8String:buf] strip];
}

static NSString* command(NSString* rb)
{
    NSString* resources = [[NSBundle mainBundle] resourcePath];
    return [NSString stringWithFormat:@"ruby -I'%@' '%@/%@'", resources, resources, rb];
}


NSMutableArray* comicsFromScript(NSString* rb)
{
    // 10 is typical, so lets be conservative
    NSMutableArray* comics = [[NSMutableArray alloc] initWithCapacity:10];
    
    FILE* pipe = popen([command(rb) UTF8String], "r+");
    if(!pipe)
        return comics;

    NSString* s;
    while(s = fgetns(pipe))
    {        
        NSURL* url = [NSURL URLWithString:s];
        NSString* ext = [[s pathExtension] lowercaseString];
        
        #define _(x) [ext isEqualToString:x]
        if(_(@"png") || _(@"jpg") || _(@"jpeg") || _(@"gif")){
            NSNumber* time = [NSNumber numberWithUnsignedInt:[fgetns(pipe) intValue]];
            NSString* title = fgetns(pipe);
            
            [comics addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               url, @"URL",
                               time, @"UTC",
                               title, @"Title",
                               rb, @"Comic",
                               nil]];
        }else{
            NSString* s = [NSString stringWithContentsOfURL:url];
            uint32_t const n = [s lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            const char* data = [s UTF8String];
            
            // first write the size of the data in network-byte-order
            uint32_t size_of_index = htonl(n);
            fwrite(&size_of_index, sizeof(size_of_index), 1, pipe);
            // now write the data itself           
            fwrite(data, sizeof(char), n, pipe);
            fflush(pipe);
        }
        #undef _
    }
    pclose(pipe);

    return comics;
}


@implementation ComicController

NSInteger sort(id a, id b, void* v)
{
    return [[a objectForKey:@"UTC"] compare:[b objectForKey:@"UTC"]];
}

void prune(NSMutableArray* comics, time_t before)
{
    NSMutableArray* toremove = [NSMutableArray array];
    NSDictionary* comic;
    for(comic in comics){
        time_t t = [[comic objectForKey:@"UTC"] unsignedIntValue];
        if(t <= before)
            [toremove addObject:comic];
    }
    [comics removeObjectsInArray:toremove];
}

NSArray* comix(NSString* rb)
{
    NSMutableArray* xkcd = comicsFromScript(rb);
    time_t before = [[[NSUserDefaults standardUserDefaults] objectForKey:rb] unsignedIntValue];
    prune(xkcd, before);
    return xkcd;
}

-(void)awakeFromNib
{
    comics = [[NSMutableArray arrayWithCapacity:20] retain];
   [comics addObjectsFromArray:comix(@"xkcd.com.rb")];
   [comics addObjectsFromArray:comix(@"explosm.net.rb")];
    comics = [[comics sortedArrayUsingFunction:sort context:nil] mutableCopy];
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
    NSDictionary* comic = [comics lastObject];
    [comics removeLastObject];
    
    NSURL* url = [comic objectForKey:@"URL"];
    NSImage* image = [[NSImage alloc] initWithContentsOfURL:url];

    if(!image)return; //TODO more
    
    [view setImage:image];

    NSRect frame = [[view window] frame];
    frame.size = [[view image] size];
    frame.size.height += titleBarHeight();
    [[view window] setFrame:frame display:true animate:true];
    
    [[view window] setTitle:[comic objectForKey:@"Title"]];
    
    [[NSUserDefaults standardUserDefaults] setObject:[comic objectForKey:@"UTC"]
                                              forKey:[comic objectForKey:@"Comic"]];
}

@end