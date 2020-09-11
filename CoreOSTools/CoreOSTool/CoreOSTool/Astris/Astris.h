//
//  Astris.h
//  CoreOSTool
//
//  Created by krisJ on 2020/1/2.
//  Copyright © 2020 Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "runTerminalCmd.h"
#import "IO/myShowString.h"


NS_ASSUME_NONNULL_BEGIN

@interface Astris : NSViewController
@property (weak) IBOutlet NSPopUpButton *fromAction;
@property (weak) IBOutlet NSPopUpButton *devicePop;
@property (weak) IBOutlet NSTextField *inputCMDTextField;
- (IBAction)sendToDevice:(id)sender;
@property (weak) IBOutlet NSTextView *astrisTextView;
- (IBAction)backward:(id)sender;

@end

NS_ASSUME_NONNULL_END
