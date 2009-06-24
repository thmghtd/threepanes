// Copyright 2009 Max Howell
#import "ComicBookGuy.h"
#import "NSString+mxcl.h"
#import "comic.h"
#define NSLog(format, ...)

@implementation PaperBoy

-(id)initWithName:(NSString*)_name shellCommand:(NSString*)cmd
{
    self = [super init];
    name = [_name retain];
    pipe = popen([cmd UTF8String], "r+");
    data = [[NSMutableData alloc] initWithCapacity:0];
    return self;
}

-(void)setConnection:(NSURLConnection*)connection
{
    http = connection;
    [http retain];
}

-(NSString*)fgetns
{   
    // http://support.microsoft.com/kb/q208427/
    // http://www.boutell.com/newfaq/misc/urllength.html
    char buf[2084];
    if(!fgets(buf, sizeof(buf), pipe))return nil;
    return [[NSString stringWithUTF8String:buf] strip];
}

-(NSString*)name
{
    return name;
}

-(NSURLConnection*)connection
{
    return http;
}

-(NSMutableData*)data
{
    return data;
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
            [boys removeObject:boy];
            if([boys count] == 0)
                [delegate performSelector:@selector(deliveriesComplete) withObject:nil];
            break;
        }
        NSURL* url = [NSURL URLWithString:s];
        NSString* ext = [[s pathExtension] lowercaseString];
        
#define _(x) [ext isEqualToString:x]
        if(_(@"png") || _(@"jpg") || _(@"jpeg") || _(@"gif")){
#undef _
            
#if __DEBUG__
            //TODO set these once in the boy object!
            time_t last_time = time(0);
            struct tm* tm = localtime(&last_time);
            tm->tm_sec = 0;
            tm->tm_min = 0;
            tm->tm_hour = 0;
            tm->tm_mday -= 2;
            last_time = mktime(tm);
#else
            time_t last_time = [[[NSUserDefaults standardUserDefaults] objectForKey:[boy name]] unsignedIntValue];
#endif
            time_t time = [[boy fgetns] integerValue];
            
            NSLog(@"td of %d for %@ for %@", last_time-time, url, [boy name]);
            
            NSString* title = [boy fgetns];
            
            if(last_time < time){
                comic_t* comic = malloc(sizeof(comic_t));
                comic->url = [url retain];
                comic->title = [title retain];
                comic->utc = time;
                comic->ident = [[boy name] retain];
                comic->www = nil;
                comic->image = nil;
                NSLog(@"Got comic! %@ for %@", url, [boy name]);
                [delegate delivery:comic];
            }
        }else{
            NSLog(@"Requesting %@ for %@", url, [boy name]);
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
    for(NSString* fn in files)
        if(![fn isEqualToString:@"threepanes.rb"])
            [scripts addObject:[fn lastPathComponent]];
    return scripts;
}

-(id)initWithDelegate:(id)_delegate
{
    self = [super init];
    delegate = _delegate;
    
    boys = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSString* resources = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"rb"];
    NSString* command = [NSString stringWithFormat:@"ruby -I'%@' '%@/'", resources, resources];
    
    for(NSString* scriptname in scripts(resources))
    {
        PaperBoy* boy = [[PaperBoy alloc] initWithName:scriptname
                                          shellCommand:[command stringByAppendingString:scriptname]];
        [boys addObject:boy];
        [self gets:boy];
    }
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

//–(void)connection:willCacheResponse:

-(void)connection:(NSURLConnection*)http didReceiveData:(NSData*)data
{
    [[find_boy(boys, http) data] appendData:data];    
}

//–(void)connection:willSendRequest:redirectResponse:
//–(void)connection:didFailWithError:
-(void)connectionDidFinishLoading:(NSURLConnection*)http
{
    PaperBoy* boy = find_boy(boys, http);
    uint32_t const n = [[boy data] length];
    
    NSLog(@"HTTP GOT %d bytes for %@", n, [boy name]);
    
    // first write the size of the data in network-byte-order
    uint32_t size_of_index = htonl(n);
    fwrite(&size_of_index, sizeof(size_of_index), 1, [boy pipe]);
    // now write the data itself           
    fwrite([[boy data] bytes], sizeof(char), n, [boy pipe]);
    fflush([boy pipe]);
    
    [http release];
    
    [self gets:boy];
}

@end
