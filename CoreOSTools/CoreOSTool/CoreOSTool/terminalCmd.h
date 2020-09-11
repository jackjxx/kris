//
//  terminalCmd.h
//  CoreOSTool
//
//  Created by Gray on 2019/10/8.
//  Copyright © 2019 ASD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface terminalCmd : NSObject

-(Boolean)_execScript:(NSString *)terminalCmd withTime:(NSTimeInterval)timeout;


@end

NS_ASSUME_NONNULL_END
