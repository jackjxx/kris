//
//  SerialPort.h
//  CommunicationPort
//
//  Created by Jerry on 15/4/24.
//  Copyright (c) 2015年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/termios.h>
#import <dirent.h>
#import "Port.h"
//#import "DebugLogInfoFile.h"

#define B460800  460800

//数据位
enum DATABITS
{
    DATA5,
    DATA6,
    DATA7,
    DATA8
};

//校验位
enum PARITYBITS
{
    PAR_EVEN,
    PAR_ODD,
    PAR_NONE
};

//停止位
enum STOPBITS
{
    STOP1,
    STOP2
};

@interface SerialPort : Port


//打开串口
- (Boolean)openPort:(NSString*)devName withBaudRate:(int)baudRate;
//设置串口波特率的大小
- (Boolean)setBaudRate:(int)baudRate;
//设置数据位大小
- (Boolean)setDataBits:(enum DATABITS)dataBits;
//设置校验位
- (Boolean)setParityBits:(enum PARITYBITS)parityBits;
//设置停止位
- (Boolean)setStopBits:(enum STOPBITS)stopBits;
//十六进制数据的字符串表示转换成内存形式数据
-(const void *)_dataFromHexString:(NSString *)hexStr dataLength:(size_t *)lenPtr;
//将十六进制字符转换成相应数值
-(unsigned char)__numberFromChar:(char)uc;
@end
