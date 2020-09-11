//
//  ViewController.h
//  CoreOSTool
//
//  Created by Gray on 2019/9/30.
//  Copyright © 2019 ASD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BootArgs/BootArgs.h"
#import "TcpRelpay/TcpRelayView.h"
#import "usbfs/usbfsView.h"
#import "Astris/Astris.h"
#import "AppDelegate.h"

@interface ViewController : NSViewController
{
    NSWindow *toolWindow;
    NSViewController* CViewController;
    BootArgs* bootArgsView;
    TcpRelayView* tcprelayView;
    usbfsView* ausbfsView;
    Astris* astrisView;
    NSArray* viewControllers;
    
}
- (IBAction)changeBootArgs:(id)sender;
@property (weak) IBOutlet NSView *mainView;
- (IBAction)showTcprelayTool:(id)sender;
- (IBAction)showUsbfsTool:(id)sender;
- (IBAction)showAstirsTool:(id)sender;

@end

