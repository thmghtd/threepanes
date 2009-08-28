// Copyright 2009 Max Howell
#import "ImageViewController.h"
#import "comic.h"



@implementation ImageViewController

-(void)awakeFromNib
{
    set_comic_when_loaded = true;
    comics = [[NSMutableArray alloc] init];
    data = [[NSMutableData alloc] init];
}

-(void)fetchNextComic
{
	assert(data.length == 0);

    if(loading)return;
    if(comics.count==0)return;
	if([comics.lastObject image])return;
	
    loading=comics.lastObject;
    [comics removeLastObject];

    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:loading.url
															cachePolicy:NSURLRequestReturnCacheDataElseLoad
														timeoutInterval:10]
								  delegate:self];
}

-(void)addComic:(Comic*)comic
{
    int const N=comics.count;
    int i=0;
    for(; i<N; ++i)
        if(comic.utc < [[comics objectAtIndex:i] utc]){
            [comics insertObject:comic atIndex:i];
            break;
        }
    if(i==N)
        [comics addObject:comic];

    if(!loading)
        [self fetchNextComic];
	
	[delegate performSelector:@selector(onComicCountChanged:) withObject:[NSNumber numberWithInt:comics.count]];
}

static void inline updateStoredTimestamp(Comic* comic)
{
    time_t now = time(NULL);
    time_t time = comic.utc;

    // sanity check the time
    if(time > now+7*24*60*60)
        time = now;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dict = [[defaults dictionaryForKey:comic.ident] mutableCopy];
    if (!dict) dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSDate dateWithTimeIntervalSince1970:time] forKey:MBLastViewedComic];
    [defaults setObject:dict forKey:comic.ident];
    [defaults synchronize];
    [dict release];
}

-(void)setComic:(Comic*)comic
{
    @try{
        NSImageRep* rep = comic.image;
        if(!rep)
            [NSException raise:@"Null image" format:@"For comic: %@", comic.url];

        // some comics (eg cad-comic) save their images with a stupid DPI
        // settings (ie. 180dpi of all things), and NSImage blindly obeys, so
        // we have to override it with this convoluted method
        comic.size = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
        
        NSImage* img = [[[NSImage alloc] init] autorelease];
        [img addRepresentation:rep];
        img.size = comic.size;
        view.image = img;
        
        updateStoredTimestamp(comic);
		[delegate performSelector:@selector(onComicCountChanged:) withObject:[NSNumber numberWithInt:comics.count]];
        [delegate performSelector:@selector(onComicChanged:) withObject:comic];
		
        set_comic_when_loaded = false;
        [self fetchNextComic];
    }
    @catch(NSException* e){
        //TODO show error to user
        NSLog(@"[UI] Load failure for %@, %@", comic.ident, comic.url);
        [self next];
    }
}

// return true if loading
-(bool)next
{
    set_comic_when_loaded = true;
    
    if(loading)
        return true;

    if(comics.count == 0){
        [delegate performSelector:@selector(onComicChanged:) withObject:nil];
        return false;
    }

    Comic* comic = [comics lastObject];

    if(comic.image){
        [comics removeLastObject];
        [self setComic:comic];
        return false; //don't show spinner
    }else{
        set_comic_when_loaded = true;
        [self fetchNextComic];
        return true;
    }
}

//TODO we must allow this http stuff to work at start, peformselectors after small delay to allow event loop to do its thing
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)newdata
{
    [data appendData:newdata];
}

-(void)connection:(NSURLConnection*) didFailWithError:(NSError*)e
{
    //TODO better
    // eg store error in comic object and then show that to delegate when asked for
    
    [NSAlert alertWithError:e];
    loading = nil;
    [self next];
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    Comic*comic=loading;
    loading = nil;

    comic.image = [[NSImageRep imageRepClassForData:data] imageRepWithData:data];
    data.length = 0;

    if(set_comic_when_loaded)
        [self setComic:comic];
	else
		[self addComic:comic];
}

-(NSUInteger)count
{
	return comics.count+(loading?1:0);
}

@end