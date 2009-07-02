// Copyright 2009 Max Howell
#import "MHImageView.h"

@implementation MHImageView

-(void)setFrame:(NSRect)newFrame
{
    // center the NSImageView in the NSScrollArea
    // http://web.mac.com/mabi99/marcocoa/blog/Entries/2008/1/1_Centered_Image_inside_a_Scroll_View.html    
    
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