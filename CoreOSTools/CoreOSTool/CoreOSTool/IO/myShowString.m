//
//  myShowString.m
//  CoreOSTool
//
//  Created by Gray on 2019/10/15.
//  Copyright © 2019 ASD. All rights reserved.
//

#import "myShowString.h"

@implementation myShowString

-(NSString*)addTxString:(NSString*)string
{
    NSDateFormatter* dateForm = [[NSDateFormatter alloc] init];
    [dateForm setDateFormat:@"YYYY-mm-dd hh:MM:ss"];
    NSDate* date = [NSDate date];
    NSString* dataString = [dateForm stringFromDate:date];
    
    return [NSString stringWithFormat:@"%@ TX --> %@\n",dataString,string];
    
}

-(NSString*)addRxString:(NSString*)string
{
    NSDateFormatter* dateForm = [[NSDateFormatter alloc] init];
    [dateForm setDateFormat:@"YYYY-mm-dd hh:MM:ss"];
    NSDate* date = [NSDate date];
    NSString* dataString = [dateForm stringFromDate:date];
    
    return [NSString stringWithFormat:@"%@ RX --> %@\n",dataString,string];
}


@end
