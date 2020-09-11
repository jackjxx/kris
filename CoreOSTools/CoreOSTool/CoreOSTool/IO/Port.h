//
//  Port.h
//  CommunicationPort
//
//  Created by Jerry on 15/4/24.
//  Copyright (c) 2015年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BUFFSIZE    8192
typedef enum
{
    DEVICE = 0,     //机台
    FIXTURE,    //治具
    MIKEY,      //mikey板
    AUX,       //aux
    HALLEFFECT,
    HALLSENSOR,
    SCRIPTTYPE,
    GPIB,
    ORION
} TargetType;

@interface Port : NSObject
{
    int _fd;
    //NSMutableData *_tempData;
}

@property (assign) int fd;
@property (nonatomic, strong) NSMutableData *stageData;

//打开指定端口
- (Boolean)openPort:(NSString*)path;
//在一定时间内读取数据，遇到结束标记停止读取
- (Boolean)readData:(NSString**)recv inTime:(NSTimeInterval)timeOut endWith:(NSString*)endSign;
//往端口发送数据
- (Boolean)writeData:(NSString*)sendData;
- (Boolean)writeDataWithTime:(NSString*)sendData
                        timeOut:(int)writeDataTimeOut;
//在一定时间内读取数据，达到指定长度时停止读取
- (NSData *)readDataInTime:(NSTimeInterval)timeOut withSize:(size_t)size;
- (Boolean)writeCString:(const unsigned char *)buff withSize:(int)size;
//关闭端口
- (Boolean)closePort;
@end
