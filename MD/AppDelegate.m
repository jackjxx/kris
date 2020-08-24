//
//  AppDelegate.m
//  MD
//
//  Created by krisJ on 2020/8/21.
//  Copyright © 2020 ASD. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
}

-(BOOL)windowShouldClose:(NSWindow *)sender
{
    [NSApp terminate:self];
    return YES;
}


@end
