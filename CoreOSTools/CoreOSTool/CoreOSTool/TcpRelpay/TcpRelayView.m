//
//  TcpRelayView.m
//  CoreOSTool
//
//  Created by Gray on 2019/10/3.
//  Copyright © 2019 ASD. All rights reserved.
//

#import "TcpRelayView.h"
#import <poll.h>
#import "foundUSB.h"
@interface TcpRelayView ()

@end

@implementation TcpRelayView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    foundUSB* finder = [[foundUSB alloc] init];
    [finder found_usb];
    _devices = finder.devices;
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(showText:) name:kShowToTheText object:nil];
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

- (NSInteger)collectionView:(nonnull NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_devices count];
}
- (nonnull NSCollectionViewItem *)collectionView:(nonnull NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(nonnull NSIndexPath *)indexPath {
    deviceCollectionItem *item = [collectionView makeItemWithIdentifier:@"deviceCollectionItem" forIndexPath:indexPath];
    int count = (int)[indexPath indexAtPosition:1];
    [item setPort:873+3*count];
    [item setItemInfo:_devices[count]];
    //    item.name.stringValue = ;
    //    NSCollectionViewFlowLayout* layout = item.collectionView.collectionViewLayout;
    //    layout.itemSize = item.view.frame.size;
    return item;
}

//- (NSSet<NSIndexPath *> *)collectionView:(NSCollectionView *)collectionView shouldSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
//{
//    _selectDevice = (deviceCollectionItem*)[_collectionView itemAtIndexPath:[indexPaths anyObject]];
//    BOOL sel = _selectDevice.isSelected;
//    return indexPaths;
//}
- (NSSet<NSIndexPath *> *)collectionView:(NSCollectionView *)collectionView shouldChangeItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths toHighlightState:(NSCollectionViewItemHighlightState)highlightState
{
    _selectDevice = (deviceCollectionItem*)[_collectionView itemAtIndexPath:[indexPaths anyObject]];
//    BOOL sel = _selectDevice.isSelected;
    return indexPaths;
}



- (NSString *)_getCMDResult:(NSString *)cmd
{
    NSString * result = @"";
    FILE *fp;
    char buf[8192];
    fp = popen([cmd UTF8String], "r");
    
    struct pollfd pfd;
    pfd.fd = fileno(fp);
    pfd.events = POLLIN;
    int pollRet;
    if ((pollRet=poll(&pfd, 1, 5*1000)) == 1)
    {
        while (fgets(buf, 8192, fp) != NULL)
        {
            result = [result stringByAppendingString:[NSString stringWithUTF8String:buf]];
        }
    }
    pclose(fp);
    return result;
}

-(Boolean)_execScript:(NSString *)terminalCmd withTime:(NSTimeInterval)timeout
{
    NSString *recv = @"";
    Boolean ret = true;
    NSString *script = @"";
    {
        FILE    *fp;    //实际运行脚本
        char    buf[1024];
        //[[task->infoToBurnDic allValues][0] length]
        if ([terminalCmd length]) //写入
        {
            script = terminalCmd;
        }
        
//        [lockForTerminalTmp lock];
        fp = popen([script UTF8String], "r");
        NSString * pidCMD = [NSString stringWithFormat:@"ps -A |pgrep -f \"%@\"|awk '{print $1}'", script];
        NSString* pid= [self _getCMDResult:pidCMD];
//        [lockForTerminalTmp unlock];
        NSString * killCMDTmp = [[NSString alloc]init];
        if (![pid isEqualToString:@""] && (pid!=nil))
        {
            pid = [pid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            while (1)
            {
                if ([pid rangeOfString:@"\n"].location != NSNotFound)
                {
                    pid = [pid substringFromIndex:[pid rangeOfString:@"\n"].location];
                    pid = [pid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                else
                {
                    NSLog(@"get thread last PID : %@", pid);
                    break;
                }
            }
            killCMDTmp = [NSString stringWithFormat:@"kill -9 %@", pid];
            NSLog(@"kill thread cmd : %@", killCMDTmp);
        }
        
        if (!fp)
        {
            NSLog(@"%s:\nrun terminal command fail!", __FUNCTION__);
            if (![pid isEqualToString:@""] && (pid!=nil))
            {
                system([killCMDTmp UTF8String]);
                NSLog(@"kill thread cmd(%@) success.", killCMDTmp);
            }
            
            return false;
        }
        if (timeout == 0)
        {
            NSLog(@"%s:\ntimeout = 0, cmd run always.", __FUNCTION__);
            
            return true;
        }
        
        struct pollfd pfd;
        pfd.fd = fileno(fp);
        pfd.events = POLLIN;
        int pollRet;
        if ( (pollRet = poll(&pfd, 1, timeout * 1000)) == 1)
        {
            while (fgets(buf, 1024, fp))
            {
                if ([NSString stringWithUTF8String:buf] != nil)
                {
                    recv = [recv stringByAppendingString:[NSString stringWithUTF8String:buf]];
                    if ([recv rangeOfString:@"$"].location != NSNotFound)    //遇到截止符，停止读取
                    {
                        break;
                    }
                }
            }
        }
        else if (pollRet < 0)
        {
            NSLog(@"%s:\nrun terminal command fail!", __FUNCTION__);
            ret = false;
        }
        system([killCMDTmp UTF8String]);
        NSLog(@"kill thread cmd(%@) success.", killCMDTmp);
        pclose(fp);
    }
    
    NSLog(@"%s:\nscript out put: %@", __FUNCTION__, recv);
    return ret;
}


- (NSString *)shellScriptActionWithLaunchPath:(NSString *)cmdPath argument:(NSArray *)argument
{
    NSTask* scriptTask = [[NSTask alloc] init];
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [scriptTask setStandardOutput: pipe];
    [scriptTask setStandardError: pipe];
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    [scriptTask setLaunchPath: cmdPath];
    [scriptTask setArguments: argument];
    [scriptTask launch];
    NSData *data;
    data = [file readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%s - got\n%@", __func__, string);
    [scriptTask waitUntilExit];
    //To-DO:vailidation for this one
    [scriptTask terminate];

    
    return string;
}

-(void)tcprelayConnect:(NSString*)locationID :(int)port
{
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* path = [mainBundle pathForResource:@"tcprelay" ofType:@""];
    
    NSString* tcprelayCMD = [NSString stringWithFormat:@"%@ --locationid %@ --portoffset 10000 %d 23",path,locationID,port];
    [self _execScript:tcprelayCMD withTime:0];
}

-(void)showText:(NSNotification*)note
{
    NSString* str = note.object;
    NSColor* color = [NSColor blueColor];
    NSAttributedString* txt = [[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName:color}];
    [[_textView textStorage] appendAttributedString:txt];
    [[_textView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\r\n"]];

}

- (IBAction)runGet:(id)sender {
//    NSBundle* mainBundle = [NSBundle mainBundle];
//    NSString* path = [mainBundle pathForResource:@"tcprelay" ofType:@""];
//
//    NSString* tcprelayCMD = [NSString stringWithFormat:@"%@ --locationid 0x%08X --portoffset 10000 873 23",path,12];
//    [self _execScript:tcprelayCMD withTime:0];
    NSString* toPath = [[NSFileManager defaultManager].homeDirectoryForCurrentUser relativeString];
    toPath = [toPath substringFromIndex:7];
    NSString* port = [NSString stringWithFormat:@"%d",_selectDevice.port+10000];

    NSString* getPath = [NSString stringWithFormat:@"rsync://root@localhost:%@/root/%@",port,[_togetPath stringValue]];
    NSString* putPath = [NSString stringWithFormat:@"%@/Desktop",toPath];
    NSString* shellPath = [[NSBundle mainBundle] pathForResource:@"cmdAndpsw" ofType:@"expect"];
    NSArray* theArguments = @[shellPath, getPath,putPath];
    NSString *string = [self shellScriptActionWithLaunchPath:@"/usr/bin/expect" argument:theArguments];
    NSColor* color = [NSColor blueColor];
    NSAttributedString* txt = [[NSAttributedString alloc] initWithString:string attributes:@{NSForegroundColorAttributeName:color}];
    [[_textView textStorage] appendAttributedString:txt];
    [[_textView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\r\n"]];
    
 
}

- (IBAction)runSet:(id)sender {
    NSString* port = [NSString stringWithFormat:@"%d",_selectDevice.port+10000];
    
    NSString* getPath = [NSString stringWithFormat:@"%@/*",_toputPath.stringValue];
    NSString* putPath = [NSString stringWithFormat:@"rsync://root@localhost:%@/root/var/root",port];
    NSString* shellPath = [[NSBundle mainBundle] pathForResource:@"cmdAndpsw" ofType:@"expect"];
    NSArray* theArguments = @[shellPath, getPath,putPath];
    NSString *string = [self shellScriptActionWithLaunchPath:@"/usr/bin/expect" argument:theArguments];
    NSColor* color = [NSColor blueColor];
       NSAttributedString* txt = [[NSAttributedString alloc] initWithString:string attributes:@{NSForegroundColorAttributeName:color}];
       [[_textView textStorage] appendAttributedString:txt];
       [[_textView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\r\n"]];
    
}
- (IBAction)backward:(id)sender {
    float x = self.view.window.frame.origin.x;
    float y = self.view.window.frame.origin.y;
    [self.view.window setFrame:NSMakeRect(x, y, 450, 270) display:YES animate:YES];
    [self.view setFrame:NSMakeRect(0, 0, 450, 270)];
//    NSLog(@"Current window size:%f,%f",self.view.window.frame.size.width,self.view.window.frame.size.height);
    NSViewController* parentView = self.parentViewController;
    [parentView transitionFromViewController:parentView.childViewControllers[3] toViewController:parentView.childViewControllers[0] options:NSViewControllerTransitionCrossfade|NSViewControllerTransitionSlideRight completionHandler:nil];
    system("killall tcprelay");
}
@end
