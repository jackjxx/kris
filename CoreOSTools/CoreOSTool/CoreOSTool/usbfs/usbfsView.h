//
//  usbfsView.h
//  CoreOSTool
//
//  Created by Gray on 2019/10/8.
//  Copyright © 2019 ASD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "deviceCollectionItem.h"
#import "runTerminalCmd.h"

NS_ASSUME_NONNULL_BEGIN

#define kShowToTheText @"ShowToTheText"

@interface usbfsView : NSViewController
@property (weak) IBOutlet NSPopUpButton *devicePop;
@property (weak) IBOutlet NSTextField *toGetFile;
@property (weak) IBOutlet NSTextField *toPutFile;
- (IBAction)getFromDevice:(id)sender;
- (IBAction)putToDevice:(id)sender;
@property (unsafe_unretained) IBOutlet NSTextView *usbfsTextView;
- (IBAction)mountDevice:(id)sender;
- (IBAction)disconnectFromLocal:(id)sender;
- (IBAction)backward:(id)sender;



@end

NS_ASSUME_NONNULL_END
