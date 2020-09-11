//
//  Port.m
//  CommunicationPort
//
//  Created by Jerry on 15/4/24.
//  Copyright (c) 2015年 Jerry. All rights reserved.
//

#import "Port.h"

@implementation Port

@synthesize fd = _fd;
//@synthesize stageData = _tempData;

//- (id)copyWithZone:(NSZone *)zone
//{
//    
//}

/**
 *  打开指定端口
 *
 *  @param path 设备或文件的路径
 *
 *  @return 成功返回true，失败返回false
 */
- (Boolean)openPort:(NSString*)path
{
    _fd = open([path UTF8String], O_RDWR | O_NONBLOCK);
    if (_fd < 0)
    {
        perror("open");
        return false;
    }

    return true;
}

/**
 *  在一定时间内读取数据，遇到结束标记停止读取
 *
 *  @param timeOut 时间限制
 *  @param recv    读取的数据通过该参数返回
 *  @param endSign 结束标记
 *
 *  @return 成功返回true，失败返回false
 */
- (Boolean)readData:(NSString* __autoreleasing*)recv inTime:(NSTimeInterval)timeOut endWith:(NSString*)endSign
{
    char recvBuf[8192];
    ssize_t nreads;
    NSDate* start;
    *recv = @"";
    self.stageData = [NSMutableData data];
    start = [NSDate date];

    //在超时或遇到结尾符之前一直读取
    while ([[NSDate date] timeIntervalSinceDate:start] < timeOut)
    {
        nreads = read(_fd, recvBuf, BUFFSIZE);
        
        if (nreads < 0)
        {
            //error log
            return false;
        }
        else if (nreads == 0)
        {
            //error log
            break;
        }
        else {
            recvBuf[nreads] = 0;
            *recv = [*recv stringByAppendingString:[NSString stringWithUTF8String:recvBuf]];
            [self.stageData appendData:[NSData dataWithBytes:recvBuf length:nreads]];

            if (endSign != NULL)
            {
                if ([*recv rangeOfString:endSign].location != NSNotFound)
                    break;
            }
        }
    }

    return true;
}

/**
 *  在一定时间内读取数据，遇到结束标记停止读取
 *
 *  @param timeOut  时间限制
 *  @param size     读取数据位数的上限
 *
 *  @返回数据类型NSData
 */
- (NSData *)readDataInTime:(NSTimeInterval)timeOut withSize:(size_t)size
{
    char recvBuf[8192];
    ssize_t nreads;
    ssize_t nbytes;
    NSDate* start;
    
    start = [NSDate date];
    
    memset(recvBuf, 0, sizeof(recvBuf));
    nbytes = 0;
    
    //read() 转为非阻塞模式
    int flags = fcntl(STDIN_FILENO, F_GETFL);
    flags |= O_NONBLOCK;
    fcntl(STDIN_FILENO, F_SETFL, flags);
    //end
    
    //在超时或读取的数据长度达到size时停止
    while ([[NSDate date] timeIntervalSinceDate:start] < timeOut)
    {
        nreads = read(_fd, recvBuf+nbytes, BUFFSIZE);
        if (nreads > 0)
            nbytes += nreads;
            
        if (nbytes >= size)
            break;
        usleep(1000);
    }
    
    NSData *retData = [[NSData alloc] initWithBytes:(const void*)recvBuf length:nbytes];
    
    if ([retData length] < 55)
        return NULL;
    
    return retData;
}

- (Boolean)writeCString:(const unsigned char *)buff withSize:(int)size
{
    while (size--)
    {
        if (write(_fd, buff++, 1) != 1)
            return false;
        usleep(1000);
    }
    
    return true;
}

/**
 *  往端口发送数据
 *
 *  @param sendData 需要发送的数据
 *
 *  @return 成功返回true，失败返回false
 */
- (Boolean)writeData:(NSString*)sendData
{
    size_t length;
    ssize_t nwrites;
    const char* csend;

    csend = [sendData cStringUsingEncoding:NSASCIIStringEncoding];

    length = [sendData length];
    
    nwrites = write(_fd, csend, length);
    
    if (nwrites < 0)
    {
        //insert error log
        return false;
    }
    else if (nwrites != length)
    {
        /*insert debug log*/;
        return false;
    }

    return true;
}

- (Boolean)writeDataWithTime:(NSString*)sendData
                     timeOut:(int)writeDataTimeOut;
{
    size_t length;
    ssize_t nwrites;
    const char* csend;
    
    csend = [sendData cStringUsingEncoding:NSASCIIStringEncoding];
    
    length = [sendData length];
    
    nwrites = write(_fd, csend, length);
    
    if (nwrites < 0)
    {
        //insert error log
        return false;
    }
    else if (nwrites != length)
    {
        /*insert debug log*/;
        return false;
    }
    
    return true;
}


/**
 *  关闭端口
 *
 *  @return 成功返回true，否则返回false
 */
- (Boolean)closePort
{
    if (_fd >= 0)
        if (close(_fd) < 0)
        {
            //insert error log
            return false;
        }
    _fd = -1;
    return true;
}
@end
