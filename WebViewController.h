// Copyright 2009 Max Howell (created on 02/02/2009)
// Licensed with GPL version 3

#import <Cocoa/Cocoa.h>
#import <WebKit/WebView.h>


@interface WebViewController : NSObject 
{
    IBOutlet WebView *webview;
    
    NSMutableArray* urls;
}
- (IBAction)next:(id)sender;


@end
