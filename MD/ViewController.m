//
//  ViewController.m
//  MDCrashTool
//
//  Created by krisJ on 2020/8/20.
//  Copyright © 2020 ASD. All rights reserved.
//

#import "ViewController.h"
#import "runTerminalCmd.h"

@implementation ViewController
@synthesize DeviceUDID;
@synthesize DeviceNum;



- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark -获取唯一UDID
- (NSString*)getUDID {
    
    runTerminalCmd *mobdevCMD = [[runTerminalCmd alloc] init];
    NSString *result = @"";
    NSString *UDID = @"";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isFileExist = [fileManager fileExistsAtPath:@"/usr/local/bin//mobdev" isDirectory:FALSE];
    if (isFileExist) {
        result = [mobdevCMD shellScriptActionWithLaunchPath:@"/usr/local/bin//mobdev" argument:@[@"list"]];
    }
    else {
        NSString *path=[[NSBundle mainBundle]pathForResource:@"mobdev" ofType:@""];
        result = [mobdevCMD shellScriptActionWithLaunchPath:path argument:@[@"list"]];
        
    }
    NSRange range = [result rangeOfString:@"(?<=UDID = )(.*)(?=, device)" options:NSRegularExpressionSearch];
    NSRange range1 = [result rangeOfString:@"(\\d)(?=\\stotal devices)" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        UDID = [result substringWithRange:range];
    }
    if (range1.location != NSNotFound) {
        NSLog(@"===>%@", [result substringWithRange:range1]);
        DeviceNum = [[result substringWithRange:range1] integerValue];
    }
    if (DeviceNum == 0) {
        [self alertinterface:@"OK" buttonWithTitle:nil messagetext:@"提示：" informativetext:@"请检查是否插入了机台！>.<"];
    }
    return UDID;
}

- (IBAction)RunCMD:(id)sender {
    DeviceUDID = [self getUDID];
    if (DeviceNum != 0) {
        runTerminalCmd *MDTool = [[runTerminalCmd alloc]init];
            NSString * toolPath = @"/System/Library/PrivateFrameworks/MobileDevice.framework/Versions/A/AppleMobileDeviceHelper.app/Contents/Resources/MDCrashReportTool";
        BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:toolPath isDirectory:FALSE];
        if (isFileExist) {
            [MDTool shellScriptActionWithLaunchPath:toolPath argument:@[@"-t",DeviceUDID]];
            [MDTool _getCMDResult:@"/usr/bin/open ~/Library/Logs/CrashReporter/MobileDevice/"];
            
        }
        else{
            NSString *path=[[NSBundle mainBundle]pathForResource:@"MDCrashReportTool" ofType:@""];
            [MDTool shellScriptActionWithLaunchPath:path argument:@[@"-t",DeviceUDID]];
            [MDTool _getCMDResult:@"/usr/bin/open ~/Library/Logs/CrashReporter/MobileDevice/"];
            
        }
    
    }
    
}

-(void)alertinterface:(NSString *)title1 buttonWithTitle:(NSString *) title2 messagetext:(NSString *)messagetext informativetext:(NSString *)informative
{
    NSAlert *alertForNotSelectIcon = [[NSAlert alloc] init];
    NSButton* button1 = [alertForNotSelectIcon addButtonWithTitle:title1];
    NSButton* button2 = [alertForNotSelectIcon addButtonWithTitle:title2];
    [alertForNotSelectIcon setMessageText:messagetext];
    [alertForNotSelectIcon setInformativeText:informative];
    [alertForNotSelectIcon setAlertStyle:NSAlertStyleWarning];
    [button1 setRefusesFirstResponder:YES];
    [button2 setRefusesFirstResponder:YES];
    [alertForNotSelectIcon beginSheetModalForWindow:self.view.window completionHandler:nil ];
}
@end
