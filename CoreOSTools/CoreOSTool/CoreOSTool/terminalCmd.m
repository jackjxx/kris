//
//  terminalCmd.m
//  CoreOSTool
//
//  Created by Gray on 2019/10/8.
//  Copyright © 2019 ASD. All rights reserved.
//

#import "terminalCmd.h"
#import <poll.h>

@implementation terminalCmd

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

@end
