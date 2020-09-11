//
//  Astris.m
//  CoreOSTool
//
//  Created by krisJ on 2020/1/2.
//  Copyright © 2020 ASD. All rights reserved.
//

#import "Astris.h"
#import <poll.h>

@implementation Astris

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSArray* ports = [self getComportName];
    [_devicePop addItemsWithTitles:ports];
    [_fromAction addItemsWithTitles:@[@"Jebdump", @"Manual"]];
    if ([ports count] == 0) {
        [[_astrisTextView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"Ensure the kanzi cable to plug into the PC please!\r\n" attributes:@{NSForegroundColorAttributeName:[NSColor redColor]}]];
    }
    [self setBackgroundColor:self.view];
}

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
            NSString *kanziDevName = [device stringByReplacingOccurrencesOfString:@"cu.kanzi-" withString:@""];
            [comportNameTmp addObject:kanziDevName];
        }
    }
    NSArray * devicesArray = [NSArray arrayWithArray:comportNameTmp];
    
    return devicesArray;
}



/*
 * /usr/local/bin/astris -nx KanziSWD-315F8E
 */

- (void)AstrisCennet
{
    runTerminalCmd* script = [[runTerminalCmd alloc] init];
    NSString* astrisCMD = [NSString stringWithFormat:@"/usr/local/bin/astris -nx KanziSWD-%@",[_devicePop titleOfSelectedItem]];
    NSString* recv = @"";
    [script _execScript:astrisCMD withTime:20 andRecv:&recv];
}

- (IBAction)sendToDevice:(id)sender
{
    NSString *endSymbol = @"NO CPU >";
    myShowString* showString = [[myShowString alloc] init];
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSDictionary* cmdlist = [NSDictionary dictionaryWithContentsOfFile:[mainBundle pathForResource:@"AstrisCMDList" ofType:@"plist"]];
    NSArray* cmds = [cmdlist objectForKey:[_fromAction titleOfSelectedItem]];
    NSMutableArray* toRunCmds = [[NSMutableArray alloc] init];
    for (NSString* cmd in cmds) {
        if ([cmd rangeOfString:@"#"].location != NSNotFound) {
            NSString* new = [cmd stringByReplacingOccurrencesOfString:@"#" withString:[_devicePop titleOfSelectedItem]];
            [toRunCmds addObject:new];
        }
        else
            [toRunCmds addObject:cmd];
    }
    if ([[_fromAction titleOfSelectedItem] isEqualToString:@"Jebdump"])
    {
        
        for (NSString* cmd in toRunCmds)
        {
            NSString *recv =[self executeCommand:cmd withEndSymbol:endSymbol];
            NSString *tmp = [showString addTxString:cmd];
            [[_astrisTextView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:tmp]];
            
            NSColor* color = [NSColor blueColor];
            NSAttributedString* txt = [[NSAttributedString alloc] initWithString:[showString addRxString:recv] attributes:@{NSForegroundColorAttributeName:color}];
            [[_astrisTextView textStorage] appendAttributedString:txt];
            [[_astrisTextView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\r\n"]];
            
            if(cmd == toRunCmds[3])
            {
                NSString *socTypeAndRev = cmd;
                if ([cmd rangeOfString:@"$"].location != NSNotFound)
                {
                    toRunCmds[4] = [toRunCmds[4] stringByReplacingOccurrencesOfString:@"$" withString:socTypeAndRev];
                }
            }
        }
    }
    if ([[_fromAction titleOfSelectedItem] isEqualToString:@"Manual"])
    {
        
        [[_astrisTextView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:[showString addRxString:@"I'm running!!!"] attributes:@{NSForegroundColorAttributeName:[NSColor blueColor]}]];
        [[_astrisTextView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\r\n"]];
        
        NSString* cable_name = [NSString stringWithFormat:@"%@", [_devicePop titleOfSelectedItem]];
        NSString* cmd = [NSString stringWithFormat:@"%@", [_inputCMDTextField stringValue]];
        NSString* shellPath = [[NSBundle mainBundle] pathForResource:@"astrisLogin" ofType:@"expect"];
        NSArray* theArguments = @[shellPath, cable_name,cmd];
        runTerminalCmd *runCMD = [[runTerminalCmd alloc]init];
        NSString *string = [runCMD shellScriptActionWithLaunchPath:@"/usr/bin/expect" argument:theArguments];
        [[_astrisTextView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:[showString addRxString:string] attributes:@{NSForegroundColorAttributeName:[NSColor blueColor]}]];
        [[_astrisTextView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\r\n"]];
        
    }
}
- (IBAction)backward:(id)sender {
    float x = self.view.window.frame.origin.x;
    float y = self.view.window.frame.origin.y;
    [self.view.window setFrame:NSMakeRect(x, y, 450, 270) display:YES animate:YES];
    [self.view setFrame:NSMakeRect(0, 0, 450, 270)];
    NSLog(@"Current window size:%f,%f",self.view.window.frame.size.width,self.view.window.frame.size.height);
    NSViewController* parentView = self.parentViewController;
    [parentView transitionFromViewController:parentView.childViewControllers[1] toViewController:parentView.childViewControllers[0] options:NSViewControllerTransitionCrossfade|NSViewControllerTransitionSlideRight completionHandler:nil];

}

- (NSString *)executeCommand: (NSString *)cmd withEndSymbol:(NSString *)endSign
 {
     NSString *output = [NSString string];
     FILE *pipe = popen([cmd cStringUsingEncoding: NSASCIIStringEncoding], "r+");
     if (!pipe)
         return @"";
     char buf[1024];
     while(fgets(buf, 1024, pipe))
     {
         output = [output stringByAppendingFormat: @"%s", buf];
         if (endSign != NULL)
         {
             if ([output rangeOfString:endSign].location != NSNotFound)
                 break;
         }
         
     }
     pclose(pipe);
     return output;
 }

@end
