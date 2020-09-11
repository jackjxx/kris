//
//  TcpRelayView.h
//  CoreOSTool
//
//  Created by Gray on 2019/10/3.
//  Copyright © 2019 ASD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "deviceCollectionItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface TcpRelayView : NSViewController<NSCollectionViewDataSource,NSCollectionViewDelegate>
- (IBAction)backward:(id)sender;

@property (weak) IBOutlet NSTextField *togetPath;
@property (weak) IBOutlet NSTextField *toputPath;
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@property NSMutableArray* devices;
@property deviceCollectionItem* selectDevice;

- (IBAction)runGet:(id)sender;
- (IBAction)runSet:(id)sender;

@end

NS_ASSUME_NONNULL_END
