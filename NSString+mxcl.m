// Copyright 2009 Max Howell
#import "NSString+mxcl.h"

@implementation NSString (mxcl)
-(NSString*)strip
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end
