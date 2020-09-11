//
//  BootArgs.h
//  CoreOSTool
//
//  Created by Gray on 2019/9/30.
//  Copyright © 2019 ASD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BootArgs : NSViewController
@property (weak) IBOutlet NSPopUpButton *devicePop;
@property (unsafe_unretained) IBOutlet NSTextView *showDetails;
@property (weak) IBOutlet NSPopUpButton *FromModel;
@property (weak) IBOutlet NSTextField *bootArgs;
- (IBAction)runCommand:(id)sender;
//- (IBAction)targetModeClick:(id)sender;
- (IBAction)backward:(id)sender;


@end

NS_ASSUME_NONNULL_END
