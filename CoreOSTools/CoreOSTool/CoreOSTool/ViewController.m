//
//  ViewController.m
//  CoreOSTool
//
//  Created by Gray on 2019/9/30.
//  Copyright © 2019 ASD. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CAMediaTimingFunction.h>
@implementation ViewController


- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    
    astrisView = [[Astris alloc]init];
    bootArgsView = [[BootArgs alloc] init];
    tcprelayView = [[TcpRelayView alloc] init];
    ausbfsView =[[usbfsView alloc] init];
    CViewController = [[NSViewController alloc] init];
    CViewController.view = _mainView;
    [CViewController insertChildViewController:self atIndex:0];
    [CViewController insertChildViewController:astrisView atIndex:1];
    [CViewController insertChildViewController:bootArgsView atIndex:2];
    [CViewController insertChildViewController:tcprelayView atIndex:3];
    [CViewController insertChildViewController:ausbfsView atIndex:4];
    
    

    toolWindow = [[NSWindow alloc]init];
    toolWindow=[NSApplication sharedApplication].windows.firstObject;
    toolWindow.alphaValue = 0.98;
    [toolWindow setTitle:@"Factory Debug Tool"];
    toolWindow.contentViewController = CViewController;
    [toolWindow center];
    [toolWindow setBackgroundColor:[NSColor colorWithRed:0.14 green:0.62 blue:0.93 alpha:1.0]];

    
    [CViewController addChildViewController:ausbfsView];
    NSLog(@"toolwindow %@ window size:%f,%f",toolWindow,toolWindow.frame.size.width,toolWindow.frame.size.height);
   
    NSLog(@"self.view.window %@ window size :%f,%f",self.view.window,self.view.window.frame.size.width,self.view.window.frame.size.height);
    
    NSLog(@"<=======分割线============>");
}


/*
 *  kris add it on 01/06/2020
 */
- (IBAction)showAstirsTool:(id)sender
{
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    float x = self.view.window.frame.origin.x;
    float y = self.view.window.frame.origin.y;
    [self.view.window setFrame:NSMakeRect(x, y,width, height+20) display:YES animate:YES];
    [self.view setFrame:NSMakeRect(0, 0, width, height+20)];
    CATransition *transitionAnimation = [[CATransition alloc] init];
    transitionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transitionAnimation.duration = 0.2;
    transitionAnimation.removedOnCompletion = true;
    transitionAnimation.type = kCATransitionPush ;//@"cube";
    transitionAnimation.subtype = kCATransitionFromLeft;
    [self.view.layer addAnimation:transitionAnimation forKey:@"transition"];
    


    [CViewController transitionFromViewController:CViewController.childViewControllers[0] toViewController:CViewController.childViewControllers[1] options:NSViewControllerTransitionCrossfade|NSViewControllerTransitionSlideUp completionHandler:nil];
    NSLog(@"Before transition window size:%f,%f",self.view.window.frame.size.width,self.view.window.frame.size.height);
}



- (IBAction)changeBootArgs:(id)sender {
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    float x = self.view.window.frame.origin.x;
    float y = self.view.window.frame.origin.y;
    [self.view.window setFrame:NSMakeRect(x, y, width+106, height+162) display:YES animate:YES];
    [self.view setFrame:NSMakeRect(0,0, width+106, height+162)];
    
    CATransition *transitionAnimation = [[CATransition alloc] init];
    transitionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transitionAnimation.duration = 0.2;
    transitionAnimation.removedOnCompletion = true;
    transitionAnimation.type = kCATransitionPush ;//@"cube";
    transitionAnimation.subtype = kCATransitionFromLeft;
    [self.view.layer addAnimation:transitionAnimation forKey:@"transition"];

    
    [CViewController transitionFromViewController:CViewController.childViewControllers[0] toViewController:CViewController.childViewControllers[2] options:NSViewControllerTransitionCrossfade|NSViewControllerTransitionSlideUp completionHandler:nil];
    NSLog(@"Before transition window size:%f,%f",self.view.window.frame.size.width,self.view.window.frame.size.height);
}

- (IBAction)showTcprelayTool:(id)sender {
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    float x = self.view.window.frame.origin.x;
    float y = self.view.window.frame.origin.y;
    [self.view.window setFrame:NSMakeRect(x, y, width+102, height+395) display:YES animate:YES];
    [self.view setFrame:NSMakeRect(0, 0, width+102, height+395)];
    
    CATransition *transitionAnimation = [[CATransition alloc] init];
    transitionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transitionAnimation.duration = 0.2;
    transitionAnimation.removedOnCompletion = true;
    transitionAnimation.type = kCATransitionPush ;//@"cube";
    transitionAnimation.subtype = kCATransitionFromLeft;
    [self.view.layer addAnimation:transitionAnimation forKey:@"transition"];
    
    [CViewController transitionFromViewController:CViewController.childViewControllers[0] toViewController:CViewController.childViewControllers[3] options:NSViewControllerTransitionCrossfade|NSViewControllerTransitionSlideUp completionHandler:nil];
    NSLog(@"Before transition window size:%f,%f",self.view.window.frame.size.width,self.view.window.frame.size.height);
}

- (IBAction)showUsbfsTool:(id)sender {
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    float x = self.view.window.frame.origin.x;
    float y = self.view.window.frame.origin.y;
    [self.view.window setFrame:NSMakeRect(x, y, width+75, height+155) display:YES animate:YES];
    [self.view setFrame:NSMakeRect(0, 0, width+75, height+155)];
    
    CATransition *transitionAnimation = [[CATransition alloc] init];
    transitionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transitionAnimation.duration = 0.2;
    transitionAnimation.removedOnCompletion = true;
    transitionAnimation.type = kCATransitionPush ;//@"cube";
    transitionAnimation.subtype = kCATransitionFromLeft;
    [self.view.layer addAnimation:transitionAnimation forKey:@"transition"];


    [CViewController transitionFromViewController:CViewController.childViewControllers[0] toViewController:CViewController.childViewControllers[4] options:NSViewControllerTransitionCrossfade|NSViewControllerTransitionSlideUp completionHandler:nil];
    NSLog(@"Before transition window size:%f,%f",self.view.window.frame.size.width,self.view.window.frame.size.height);
}


@end
