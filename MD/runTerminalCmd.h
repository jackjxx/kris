//
//  runTerminalCmd.h
//  CoreOSTool
//
//  Created by Gray on 2019/11/29.
//  Copyright © 2019 ASD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface runTerminalCmd : NSObject

- (NSString *)_getCMDResult:(NSString *)cmd;

-(Boolean)_execScript:(NSString *)terminalCmd withTime:(NSTimeInterval)timeout andRecv:(NSString * _Nonnull*_Nonnull)recv;

- (NSString *)shellScriptActionWithLaunchPath:(NSString *)cmdPath argument:(NSArray *)argument;

@end

NS_ASSUME_NONNULL_END
