//
//  deviceCollectionItem.m
//  CoreOSTool
//
//  Created by Gray on 2019/11/29.
//  Copyright © 2019 ASD. All rights reserved.
//

#import "deviceCollectionItem.h"
#import "runTerminalCmd.h"

@interface deviceCollectionItem ()

@end

@implementation deviceCollectionItem

@synthesize port;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.view.wantsLayer = YES;
    self.view.layer.borderColor = [[NSColor blueColor] CGColor];
    self.view.layer.borderWidth = 0;
}
- (BOOL)isSelected
{
    if ([super isSelected]) {
        self.view.layer.borderWidth = 3;
    }
    else
        self.view.layer.borderWidth = 0;
    return [super isSelected];

}
-(void)setItemInfo:(NSDictionary*)dic
{
    _name.stringValue = [dic objectForKey:@"devname"];
    _serialNumber.stringValue = [dic objectForKey:@"serialNumber"];
    _locationID.stringValue = [dic objectForKey:@"locationID"];
    _version.stringValue = [dic objectForKey:@"version"];
}

- (void)rightMouseDown:(NSEvent *)event;
{
    NSMenu* menu = [self menuForEvent:event];
    [self.view setMenu:menu];
    [NSMenu popUpContextMenu:menu withEvent:event forView:self.view];
}
- (nullable NSMenu *)menuForEvent:(NSEvent *)event
{
    NSMenu* menu = [[NSMenu alloc] initWithTitle:@"help"];
    [menu insertItemWithTitle:@"连接" action:@selector(tcprelayConnect) keyEquivalent:@"" atIndex:0];
    return menu;
}

-(void)tcprelayConnect
{
    runTerminalCmd* script = [[runTerminalCmd alloc] init];
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* path = [mainBundle pathForResource:@"tcprelay" ofType:@""];
    
    NSString* tcprelayCMD = [NSString stringWithFormat:@"%@ --locationid %@ --portoffset 10000 %d 23",path,_locationID.stringValue,port];
    NSString* recv = @"";
    [script _execScript:tcprelayCMD withTime:0 andRecv:&recv];
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kShowToTheText object:recv];
    
    if ([recv rangeOfString:@"Error"].location == NSNotFound) {
        NSImageView* img = [NSImageView imageViewWithImage:[NSImage imageNamed:@"gou"]];
        [img setFrameOrigin:NSMakePoint(120, 50)];
        [img setFrameSize:NSMakeSize(30, 30)];
        [self.view addSubview:img];
    }
}

@end
