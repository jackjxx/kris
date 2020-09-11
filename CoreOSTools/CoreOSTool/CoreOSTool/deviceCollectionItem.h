//
//  deviceCollectionItem.h
//  CoreOSTool
//
//  Created by Gray on 2019/11/29.
//  Copyright © 2019 ASD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

#define kShowToTheText @"ShowToTheText"

@interface deviceCollectionItem : NSCollectionViewItem
@property (weak) IBOutlet NSTextField *name;
@property (weak) IBOutlet NSTextField *version;
@property (weak) IBOutlet NSTextField *serialNumber;
@property (weak) IBOutlet NSTextField *locationID;

@property int port;


-(void)setItemInfo:(NSDictionary*)dic;

@end

NS_ASSUME_NONNULL_END
