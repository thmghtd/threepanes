// Copyright 2009 Max Howell
#import "ImageViewController.h"
#import "comic.h"

// center the NSImageView in the NSScrollArea
// http://web.mac.com/mabi99/marcocoa/blog/Entries/2008/1/1_Centered_Image_inside_a_Scroll_View.html
@interface NSImageView (mxcl)
@end
@implementation NSImageView (mxcl)
-(void)setFrame:(NSRect)newFrame
{
    NSSize superSize = ((NSClipView*)_superview).frame.size;
    NSSize imageSize = ((NSImage*)[self image]).size;

    newFrame.size.width = MAX(imageSize.width, superSize.width);
    newFrame.size.height = MAX(imageSize.height, superSize.height);
    
    if(imageSize.width > superSize.width)
        newFrame.origin.x = (superSize.width-imageSize.width)/2;
    else
        newFrame.origin.x = 0; // otherwise off by one errors seem to propogate
   
    [super setFrame:newFrame];
}
/** pin content as expected, not bottom-left! */
-(BOOL)isFlipped
{
    return true;
}
@end


@implementation ImageViewController

-(void)awakeFromNib
{
    dodelegate = true;
    waiting_for_next = true;
    comics = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsOpaqueMemory];
    data = [[NSMutableData data] retain];
}

-(NSURLConnection*)fetch:(comic_t*)comic
{
    assert([data length] == 0);

    NSLog(@"Fetching: %@", comic->url);
    NSURLRequest* rq = [NSURLRequest requestWithURL:comic->url
                                        cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                    timeoutInterval:10];
    return [NSURLConnection connectionWithRequest:rq delegate:self];
}

-(void)addComic:(comic_t*)comic
{
    if(waiting_for_next){
        http = [self fetch:comic];
        active = comic;
        waiting_for_next = false;
    }
    else if([comics count] == 0){
        [comics addPointer:comic];
        if(!active){
            http = [self fetch:comic];
            active = comic;
        }
    }
    else { for(int x = 0; x < [comics count]; ++x){
        comic_t* b = [comics pointerAtIndex:x];
        if(comic->utc < b->utc){
            [comics insertPointer:comic atIndex:x];
            return;
        }
    }
        [comics addPointer:comic];
    }
}

static void inline updateStoredTimestamp(comic_t* comic)
{
    time_t now = time(NULL);
    time_t time = comic->utc;

    // sanity check the time
    if(time > now+7*24*60*60)
        time = now;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInt:time]
                                              forKey:comic->ident];
}

-(void)setComic:(comic_t*)comic
{
    @try{
        NSImageRep* rep = comic->image;
        if(!rep)
            [NSException raise:@"Null image" format:@"For comic: %@", comic->url];

        // some comics (eg cad-comic) save their images with a stupid DPI
        // settings (ie. 180dpi of all things), and NSImage blindly obeys, so
        // we have to override it with this convuluted method
        comic->size = NSMakeSize([rep pixelsWide], [rep pixelsHigh]);
        
        NSImage* img = [[[NSImage alloc] init] autorelease];
        [img addRepresentation:rep];
        [img setSize:comic->size];
        [view setImage:img];
        
        updateStoredTimestamp(comic);
        [delegate onComicChanged:comic];
        dodelegate = false;

        if([comics count]){
            comic_t* nextcomic = [comics pointerAtIndex:0];
            http = [self fetch:nextcomic];
            active = nextcomic;
        }
    }
    @catch(NSException* e){
        //TODO log exception
        NSLog(@"Load failure for %@, %@", comic->ident, comic->url);
        [self next];
    }
}

-(bool)next
{
    if(active||http){ // already on it
        dodelegate = true;
        return true;
    }
    if([comics count] == 0){
        [delegate onComicChanged:NULL];
        waiting_for_next = true;
        dodelegate = true;
        return false;
    }

    comic_t* comic = [comics pointerAtIndex:0];
    if(comic->image){
        // we already downloaded it
        [comics removePointerAtIndex:0];
        dodelegate = true;
        [self setComic:comic];
        return false; //don't show spinner
    }else{
        http = [self fetch:comic];
        active = comic;
        dodelegate = true;
        return true;
    }
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)newdata
{
    if(connection == http)
        [data appendData:newdata];
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    if(connection == http){
        NSLog(@"Fetched: %@", active->url);
        
        comic_t* comic = active;
        active = nil;
        http = nil;

        comic->image = [[[NSImageRep imageRepClassForData:data] imageRepWithData:data] retain];
        [data setLength:0];
        
        if(dodelegate){
            if([comics count])
                [comics removePointerAtIndex:0]; //FIXME lol
            [self setComic:comic];
        }
    }
}

-(NSUInteger)count
{
    return [comics count];
}

@end