//
//  BootArgs.m
//  CoreOSTool
//
//  Created by Gray on 2019/9/30.
//  Copyright © 2019 ASD. All rights reserved.
//

#import "BootArgs.h"
#import "IO/SerialPort.h"
#import "IO/myShowString.h"
@interface BootArgs ()

@end

@implementation BootArgs

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSArray* ports = [self getComportName];
    [_devicePop addItemsWithTitles:ports];
    [_FromModel addItemsWithTitles:@[@"iBoot",@"OS Diags",@"EFI Diags"]];
//    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
//    [nc addObserver:self selector:@selector(changeTargetModelPop:) name:NSPopUpButtonWillPopUpNotification object:nil];
//    for (NSMenuItem* item in [_FromModel itemArray]) {
//        [item setTarget:self];
//        [item setAction:@selector(justNol:)];
//    }
//    [_ToModel setAction:@selector(setTheCmdList)];
    if ([ports count] == 0) {
        [[_showDetails textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"Ensure the kanzi cable to plug into the PC please!\r\n" attributes:@{NSForegroundColorAttributeName:[NSColor redColor]}]];
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


- (IBAction)runCommand:(id)sender {
    myShowString* showString = [[myShowString alloc] init];
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSDictionary* cmdlist = [NSDictionary dictionaryWithContentsOfFile:[mainBundle pathForResource:@"CMDList" ofType:@"plist"]];
    NSArray* cmds = [cmdlist objectForKey:[_FromModel titleOfSelectedItem]];
    NSMutableArray* toRunCmds = [[NSMutableArray alloc] init];
    for (NSString* cmd in cmds) {
        if ([cmd rangeOfString:@"#"].location != NSNotFound) {
            NSString* new = [cmd stringByReplacingOccurrencesOfString:@"#" withString:[_bootArgs stringValue]];
            [toRunCmds addObject:new];
        }
        else
            [toRunCmds addObject:cmd];
    }

    NSString* endSympal = @"";
    if ([[_FromModel titleOfSelectedItem] isEqualToString:@"iBoot"])
        endSympal = @"]";
    else if ([[_FromModel titleOfSelectedItem] isEqualToString:@"OS Diags"])
        endSympal = @"root#";
    else
        endSympal = @":-)";
    SerialPort* devicePort = [[SerialPort alloc] init];
    [devicePort openPort:[_devicePop titleOfSelectedItem] withBaudRate:115200];
    for (NSString* cmd in toRunCmds) {
        if([devicePort writeData:cmd])
        {
            NSString* tmp = [showString addTxString:cmd];
            [[_showDetails textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:tmp]];

            NSString* recv = @"";
            [devicePort readData:&recv inTime:5 endWith:endSympal];
            NSColor* color = [NSColor blueColor];
            NSAttributedString* txt = [[NSAttributedString alloc] initWithString:[showString addRxString:recv] attributes:@{NSForegroundColorAttributeName:color}];
            [[_showDetails textStorage] appendAttributedString:txt];
            [[_showDetails textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\r\n"]];
        }

    }
}
- (void)changeTargetModelPop:(NSNotification*)notification
{
    NSLog(@"vv");
//    NSBundle* mainBundle = [NSBundle mainBundle];
//    NSDictionary* cmdlist = [NSDictionary dictionaryWithContentsOfFile:[mainBundle pathForResource:@"CMDList" ofType:@"plist"]];
//    NSArray* cmds = [cmdlist objectForKey:[_FromModel titleOfSelectedItem]];
//    [_cmdPop addItemsWithTitles:cmds];
}

//-(void)setTheCmdList
//{
//    NSBundle* mainBundle = [NSBundle mainBundle];
//    NSDictionary* cmdlist = [NSDictionary dictionaryWithContentsOfFile:[mainBundle pathForResource:@"CMDList" ofType:@"plist"]];
//    NSArray* cmds = [cmdlist objectForKey:[_FromModel titleOfSelectedItem]];
//    [_cmdPop addItemsWithTitles:cmds];
//}
//
//- (IBAction)targetModeClick:(id)sender {
//    NSBundle* mainBundle = [NSBundle mainBundle];
//    NSDictionary* cmdlist = [NSDictionary dictionaryWithContentsOfFile:[mainBundle pathForResource:@"CMDList" ofType:@"plist"]];
//    NSArray* cmds = [cmdlist objectForKey:[_FromModel titleOfSelectedItem]];
//    [_cmdPop addItemsWithTitles:cmds];
//
//}
- (IBAction)backward:(id)sender {
    float x = self.view.window.frame.origin.x;
    float y = self.view.window.frame.origin.y;
    [self.view.window setFrame:NSMakeRect(x, y, 450, 270) display:YES animate:YES];
    [self.view setFrame:NSMakeRect(0, 0, 450, 270)];
    NSLog(@"Current window size:%f,%f",self.view.window.frame.size.width,self.view.window.frame.size.height);
    NSViewController* parentView = self.parentViewController;
    [parentView transitionFromViewController:parentView.childViewControllers[2] toViewController:parentView.childViewControllers[0] options:NSViewControllerTransitionCrossfade|NSViewControllerTransitionSlideRight completionHandler:nil];

}
@end
