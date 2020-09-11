//
//  usbfsView.m
//  CoreOSTool
//
//  Created by Gray on 2019/10/8.
//  Copyright © 2019 ASD. All rights reserved.
//

#import "usbfsView.h"
#import "terminalCmd.h"
#import "IO/SerialPort.h"

@interface usbfsView ()

@end

@implementation usbfsView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSArray* ports = [self getComportName];
    [_devicePop addItemsWithTitles:ports];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(showText:) name:kShowToTheText object:nil];
    
//    [nc postNotificationName:kShowToTheText object:recv];
    if ([ports count] == 0) {
        [[_usbfsTextView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"Ensure the kanzi cable to plug into the PC please!\r\n" attributes:@{NSForegroundColorAttributeName:[NSColor redColor]}]];
    }
    [self setBackgroundColor:self.view];
}
/*
 *   kris add it on 1/13/2020
 */
- (void)setBackgroundColor:(NSView *)view
{
    CALayer *viewLayer = [CALayer layer];
    NSView *backgroundView = view;
    [backgroundView setWantsLayer:YES];
    [backgroundView setLayer:viewLayer];
    backgroundView.layer.backgroundColor = [NSColor colorWithRed:0.14 green:0.62 blue:0.93 alpha:1.0].CGColor;
    
}

-(void)showText:(NSNotification*)note
{
    NSString* str = note.object;
    NSColor* color = [NSColor blueColor];
    NSAttributedString* txt = [[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName:color}];
    [[_usbfsTextView textStorage] appendAttributedString:txt];
    [[_usbfsTextView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\r\n"]];

}

- (NSArray *)getComportName
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * devices = [fileManager contentsOfDirectoryAtPath:@"/dev/" error:nil];
    NSMutableArray * comportNameTmp = [[NSMutableArray alloc]init];
    for (NSString *device in devices)
    {
        if ([device rangeOfString:@"cu.kanzi-"].location != NSNotFound)
        {
            NSString *devName = [device stringByReplacingOccurrencesOfString:@"cu.kanzi-" withString:@""];
            [comportNameTmp addObject:devName];
        }
    }
    NSArray * devicesArray = [NSArray arrayWithArray:comportNameTmp];
    
    return devicesArray;
}


- (IBAction)getFromDevice:(id)sender {
    NSString *portName = [_devicePop selectedItem].title;
    SerialPort *devicePort = [[SerialPort alloc] init];
    [devicePort openPort:portName withBaudRate:115200];
    NSString *usbfsPath = @"/usr/local/bin//usbfs";
    if ([[NSFileManager defaultManager] fileExistsAtPath:usbfsPath]) {
        [devicePort writeData:[NSString stringWithFormat:@"usbfs --mount %@",portName]];
    } else {
        [devicePort writeData:[NSString stringWithFormat:@"%@ --mount %@",[[NSBundle mainBundle] pathForResource:@"usbfs" ofType:@""],portName]];
    }
    NSString* recv = @"";
    [devicePort readData:&recv inTime:5 endWith:@":-)"];
    
    [devicePort writeData:[NSString stringWithFormat:@"cp nandfs:%@ usbfs:\\",_toGetFile.stringValue]];
    [devicePort readData:&recv inTime:5 endWith:@":-)"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowToTheText object:recv];
}

- (IBAction)putToDevice:(id)sender {
    
    NSString* portName = [_devicePop selectedItem].title;
    SerialPort* devicePort = [[SerialPort alloc] init];
    [devicePort openPort:portName withBaudRate:115200];
    
    [devicePort writeData:[NSString stringWithFormat:@"usbfs --mount %@",portName]];
    NSString* recv = @"";
    [devicePort readData:&recv inTime:5 endWith:@":-)"];
    
    [devicePort writeData:[NSString stringWithFormat:@"cp usbfs://%@ nandfs:\\private\var\tmp",_toPutFile.stringValue]];
    [[_usbfsTextView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"Copying files to nandfs:\\private\var\tmp \r\n" attributes:@{NSForegroundColorAttributeName:[NSColor blueColor]}]];
    [devicePort readData:&recv inTime:5 endWith:@":-)"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowToTheText object:recv];
}

- (IBAction)mountDevice:(id)sender {
    terminalCmd* mountCmd = [[terminalCmd alloc] init];
    NSString* desktopPath = [NSString stringWithFormat:@"%@/Desktop/",[[NSFileManager defaultManager].homeDirectoryForCurrentUser absoluteString]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isFileExist = [fileManager fileExistsAtPath:@"/usr/local/bin//usbfs" isDirectory:&isDir];
    if (isFileExist) {
        NSString* cmd = [NSString stringWithFormat:@"usbfs -f %@",desktopPath];
        [mountCmd _execScript:cmd withTime:0];
    }
    else {
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSString* path = [mainBundle pathForResource:@"usbfs" ofType:@""];
        NSString* cmd = [NSString stringWithFormat:@"%@ -f %@",path,desktopPath];
        [mountCmd _execScript:cmd withTime:0];
    }
    

}

- (IBAction)disconnectFromLocal:(id)sender {
    NSString * pid = [NSString stringWithFormat:@"ps -A |pgrep -f \"usbfs\"|awk '{print $1}'"];
    NSString * killCMDTmp = [[NSString alloc]init];
    killCMDTmp = [NSString stringWithFormat:@"kill -9 %@", pid];
    system([killCMDTmp UTF8String]);
}

- (IBAction)backward:(id)sender {
    float x = self.view.window.frame.origin.x;
    float y = self.view.window.frame.origin.y;
    [self.view.window setFrame:NSMakeRect(x, y, 450, 270) display:YES animate:YES];
    [self.view setFrame:NSMakeRect(0, 0, 450, 270)];
    NSLog(@"Current window size:%f,%f",self.view.window.frame.size.width,self.view.window.frame.size.height);
    NSViewController* parentView = self.parentViewController;
    [parentView transitionFromViewController:parentView.childViewControllers[4] toViewController:parentView.childViewControllers[0] options:NSViewControllerTransitionCrossfade|NSViewControllerTransitionSlideRight completionHandler:nil];
}


@end
