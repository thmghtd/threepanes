// Copyright 2009 Max Howell
#import "PaperBoy.h"
#import "NSString+mxcl.h"
#import "comic.h"
//#define NSLog(format, ...)

@implementation Comic
@synthesize image;
@synthesize title;
@synthesize utc;
@synthesize url;
@synthesize ident;
@synthesize size;
@end


@implementation PublishingHouse

-(NSString*)fgetns
{
    // http://support.microsoft.com/kb/q208427/
    // http://www.boutell.com/newfaq/misc/urllength.html
    char buf[2084];
    if(!fgets(buf, sizeof(buf), pipe))return nil;
    return [[NSString stringWithUTF8String:buf] strip];
}

-(id)initWithName:(NSString*)myid shellCommand:(NSString*)cmd
{
    NSLog(@"[PB] exec: %@", cmd);
    
    self = [super init];
    identifier = [myid retain];
    pipe = popen([cmd UTF8String], "r+");
    name = [[self fgetns] retain];
    genre = [[self fgetns] retain];
    data = [[NSMutableData alloc] initWithCapacity:0];
    enabled = true;

    return self;
}

@synthesize http;
@synthesize data;
@synthesize name;
@synthesize pipe;
@synthesize identifier;

@end


static PublishingHouse* find_house(NSArray* houses, NSURLConnection* http)
{
    for(PublishingHouse* h in houses)
        if(h.http == http)
            return h;
    return nil;
}


@implementation PaperBoy

-(void)gets:(PublishingHouse*)boy
{   
    for(;;){
        NSString* s = [boy fgetns];
        if(!s){
            [fetching removeObject:boy];
            if(fetching.count == 0 && scripts.count == 0)
                [delegate performSelector:@selector(deliveriesComplete) withObject:nil];
            break;
        }
        NSURL* url = [NSURL URLWithString:s];
        NSString* ext = [[s pathExtension] lowercaseString];
        
#define _(x) [ext isEqualToString:x]
        if(_(@"png") || _(@"jpg") || _(@"jpeg") || _(@"gif")){
#undef _
            Comic* comic = [[Comic alloc] init];
            comic.url=url;
            comic.utc=[[boy fgetns] integerValue];
            comic.title=[boy fgetns];
            comic.ident=[boy identifier];

            NSLog(@"[PB] OHAI: %@", url);
            [delegate performSelector:@selector(delivery:) withObject:comic];
        }else{
            NSLog(@"[PB] HTTP GET %@", url);
            boy.http = [[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url]
                                                     delegate:self] retain];
            break;
        }
    }
}

-(void)execNextScript
{
	if(scripts.count==0){
		if(fetching.count == 0)
			// we do this here because if we never fetched anything then this never
			// gets called, a rare usecase agreed, but still possible annoyingly
			// of course this way it *may* get called twice, but meh
			[delegate performSelector:@selector(deliveriesComplete)];
		return;
	}
	
	NSString* scriptname = [[[scripts lastObject] retain] autorelease];
	[scripts removeLastObject];

#ifdef __DEBUG__
	time_t last_time = time(0);
    struct tm* tm = localtime(&last_time);
    tm->tm_sec = 0;
    tm->tm_min = 0;
    tm->tm_hour = 0;
    tm->tm_mday -= 2;
    last_time = mktime(tm);
#else
	NSDictionary* dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:scriptname];
	NSDate* date = [dict objectForKey:MBLastViewedComic];
	uint32_t last_time = (uint32_t)[date timeIntervalSince1970];
#endif

	PublishingHouse* house = [[PublishingHouse alloc] initWithName:scriptname
													  shellCommand:[NSString stringWithFormat:@"ruby '%@' %u", scriptname, last_time]];
	[houses addObject:house];

	bool is_active = [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:scriptname] objectForKey:MBComicEnabled] boolValue];
	if(is_active){
		[fetching addObject:house];
		[self gets:house];
	}
	
	// we do this asyncronously with a delay to prevent the UI ceasing
	// and to ensure we get the first comic more quickly
	[self performSelector:@selector(execNextScript) withObject:nil afterDelay:0.0];
}

-(id)initWithDelegate:(id)_delegate
{
    self = [super init];
    delegate = _delegate;
    
    houses = [[NSMutableArray alloc] initWithCapacity:10];
    fetching = [[NSMutableArray alloc] initWithCapacity:10];

	NSFileManager* fm = [NSFileManager defaultManager];
	
	// this way we don't have to escape any paths passed to popen
	[fm changeCurrentDirectoryPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"rb"]];
	
	NSArray* files = [fm directoryContentsAtPath:@"."];
    scripts = [[NSMutableArray arrayWithCapacity:[files count]] retain];
    for (NSString* fn in files)
        if (![fn isEqualToString:@"threepanes.rb"] && ![fn isEqualToString:@"template.rb"])
            [scripts addObject:[fn lastPathComponent]];

	[self execNextScript];

	return self;
}

-(void)connection:(NSURLConnection*)http didReceiveResponse:(NSHTTPURLResponse*)response
{
    [[find_house(houses, http) data] setLength:0];
    
    if(response.statusCode == 404){
        [http cancel];
        [self connectionDidFinishLoading:http];
    }
}

//-(void)connection:willCacheResponse:

-(void)connection:(NSURLConnection*)http didReceiveData:(NSData*)data
{
    [[find_house(houses, http) data] appendData:data];    
}

//TODO -(void)connection:willSendRequest:redirectResponse:
//TODO -(void)connection:didFailWithError:
-(void)connectionDidFinishLoading:(NSURLConnection*)http
{
    PublishingHouse* boy = find_house(houses, http);
    uint32_t const n = [[boy data] length];
    
    // first write the size of the data in network-byte-order
    uint32_t size_of_index = htonl(n);
    fwrite(&size_of_index, sizeof(size_of_index), 1, [boy pipe]);
    // now write the data itself           
    fwrite([[boy data] bytes], sizeof(char), n, [boy pipe]);
    fflush([boy pipe]);
    
    [http release];
    
    [self gets:boy];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView*)view
{
    return [houses count];
}

-(id)tableView:(NSTableView*)view objectValueForTableColumn:(NSTableColumn*)col row:(NSInteger)row
{
    PublishingHouse* boy = [houses objectAtIndex:row];
    
    if([col.identifier isEqualToString:@"enabled"]){
        [[col dataCellForRow:row] setTitle:boy.name];
        int state = [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:boy.identifier] objectForKey:MBComicEnabled] boolValue];
        return [NSNumber numberWithInteger:state];
    }
    else 
        return [boy valueForKey:col.identifier];
}


-(void)tableView:(NSTableView*)view setObjectValue:(id)o forTableColumn:(NSTableColumn*)col row:(NSInteger)row
{
    if(![[col identifier] isEqualToString:@"enabled"])return;

    PublishingHouse* boy = [houses objectAtIndex:row];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dict = [[defaults dictionaryForKey:boy.identifier] mutableCopy];
    if (!dict) dict = [[NSMutableDictionary alloc] init];
    [dict setObject:o forKey:MBComicEnabled];
    [defaults setObject:dict forKey:boy.identifier];
    [defaults synchronize];
    [dict release];
}

@end
