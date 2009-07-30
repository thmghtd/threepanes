// Copyright 2009 Max Howell
#import "ComicBookGuy.h"
#import "NSString+mxcl.h"
#import "comic.h"
//#define NSLog(format, ...)

@implementation PaperBoy

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
    NSLog(cmd);
    
    self = [super init];
    identifier = [myid retain];
    pipe = popen([cmd UTF8String], "r+");
    name = [[self fgetns] retain];
    genre = [[self fgetns] retain];
    data = [[NSMutableData alloc] initWithCapacity:0];
    enabled = true;

    return self;
}

-(void)setConnection:(NSURLConnection*)connection
{
    http = connection;
    [http retain];
}

-(NSString*)id
{
    return identifier;
}

-(NSURLConnection*)connection
{
    return http;
}

-(NSMutableData*)data
{
    return data;
}

-(NSString*)name
{
    return name;
}

-(FILE*)pipe
{
    return pipe;
}
@end


static PaperBoy* find_boy(NSArray* boys, NSURLConnection* http)
{
    for(PaperBoy* boy in boys)
        if([boy connection] == http)
            return boy;
    return nil;
}


@implementation ComicBookGuy

-(void)gets:(PaperBoy*)boy
{   
    for(;;){
        NSString* s = [boy fgetns];
        if(!s){
            [fetching removeObject:boy];
            if([fetching count] == 0)
                [delegate performSelector:@selector(deliveriesComplete) withObject:nil];
            break;
        }
        NSURL* url = [NSURL URLWithString:s];
        NSString* ext = [[s pathExtension] lowercaseString];
        
#define _(x) [ext isEqualToString:x]
        if(_(@"png") || _(@"jpg") || _(@"jpeg") || _(@"gif")){
#undef _
            comic_t* comic = malloc(sizeof(comic_t));
            comic->url = [url retain];
            comic->utc = [[boy fgetns] integerValue];
            comic->title = [[boy fgetns] retain];
            comic->ident = [[boy id] retain];
            comic->www = nil;
            comic->image = nil;
            NSLog(@"Got comic! %@ for %@", url, [boy id]);
            [delegate delivery:comic];
        }else{
            NSLog(@"Requesting %@ for %@", url, [boy id]);
            [boy setConnection:[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url]
                                                             delegate:self]];
            break;
        }
    }
}

static inline NSArray* scripts(NSString* path)
{
    NSArray* files = [[NSFileManager defaultManager] directoryContentsAtPath:path];
    NSMutableArray* scripts = [NSMutableArray arrayWithCapacity:[files count]];
    for (NSString* fn in files)
        if (![fn isEqualToString:@"threepanes.rb"] && ![fn isEqualToString:@"template.rb"])
            [scripts addObject:[fn lastPathComponent]];
    return scripts;
}

-(id)initWithDelegate:(id)_delegate
{    
    self = [super init];
    delegate = _delegate;
    
    boys = [[NSMutableArray alloc] initWithCapacity:10];
    fetching = [[NSMutableArray alloc] initWithCapacity:10];
    
#if __DEBUG__
    time_t last_time = time(0);
    struct tm* tm = localtime(&last_time);
    tm->tm_sec = 0;
    tm->tm_min = 0;
    tm->tm_hour = 0;
    tm->tm_mday -= 2;
    last_time = mktime(tm);
#endif   

    NSString* resources = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"rb"];
    NSString* command = [NSString stringWithFormat:@"ruby -I'%@' '%1$@/%%@' %%u", resources];
    
    for(NSString* scriptname in scripts(resources))
    {
//    #ifndef __DEBUG__
        NSDictionary* dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:scriptname];
        NSDate* date = [dict objectForKey:MBLastViewedComic];
        uint32_t last_time = (uint32_t)[date timeIntervalSince1970];
//    #endif
        
        PaperBoy* boy = [[PaperBoy alloc] initWithName:scriptname
                                          shellCommand:[NSString stringWithFormat:command, scriptname, last_time]];
        [boys addObject:boy];

        NSNumber* active = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:scriptname] objectForKey:MBComicEnabled];
        if ([active boolValue]){
            [fetching addObject:boy];
            [self gets:boy];
        }
    }
    
    if([fetching count] == 0)
        [delegate performSelector:@selector(deliveriesComplete)];
    
    return self;
}

-(void)connection:(NSURLConnection*)http didReceiveResponse:(NSHTTPURLResponse*)response
{
    [[find_boy(boys, http) data] setLength:0];
    
    if([response statusCode] == 404){
        [http cancel];
        [self connectionDidFinishLoading:http];
    }
}

//-(void)connection:willCacheResponse:

-(void)connection:(NSURLConnection*)http didReceiveData:(NSData*)data
{
    [[find_boy(boys, http) data] appendData:data];    
}

//TODO -(void)connection:willSendRequest:redirectResponse:
//TODO -(void)connection:didFailWithError:
-(void)connectionDidFinishLoading:(NSURLConnection*)http
{
    PaperBoy* boy = find_boy(boys, http);
    uint32_t const n = [[boy data] length];
    
    NSLog(@"HTTP GOT %d bytes for %@", n, [boy id]);
    
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
    return [boys count];
}

-(id)tableView:(NSTableView*)view objectValueForTableColumn:(NSTableColumn*)col row:(NSInteger)row
{
    PaperBoy* boy = [boys objectAtIndex:row];
    
    if([col.identifier isEqualToString:@"enabled"]){
        [[col dataCellForRow:row] setTitle:boy.name];
        int state = [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:boy.id] objectForKey:MBComicEnabled] boolValue];
        return [NSNumber numberWithInteger:state];
    }
    else 
        return [boy valueForKey:col.identifier];
}


-(void)tableView:(NSTableView*)view setObjectValue:(id)o forTableColumn:(NSTableColumn*)col row:(NSInteger)row
{
    if(![[col identifier] isEqualToString:@"enabled"])return;

    PaperBoy* boy = [boys objectAtIndex:row];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dict = [[defaults dictionaryForKey:boy.id] mutableCopy];
    if (!dict) dict = [[NSMutableDictionary alloc] init];
    [dict setObject:o forKey:MBComicEnabled];
    [defaults setObject:dict forKey:boy.id];
    [defaults synchronize];
    [dict release];
}

@end
