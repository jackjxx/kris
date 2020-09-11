//
//  foundUSB.h
//  CoreOSTool
//
//  Created by Gray on 2019/11/28.
//  Copyright © 2019 ASD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/usb/IOUSBLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface foundUSB : NSObject

@property CFMutableDictionaryRef dict;
@property uint32 locationID;
@property NSMutableArray* devices;
@property NSMutableDictionary* device;

-(void)found_usb;

@end

NS_ASSUME_NONNULL_END
