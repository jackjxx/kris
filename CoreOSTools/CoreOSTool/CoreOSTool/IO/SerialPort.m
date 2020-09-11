//
//  SerialPort.m
//  CommunicationPort
//
//  Created by Jerry on 15/4/24.
//  Copyright (c) 2015年 Jerry. All rights reserved.
//

#import "SerialPort.h"

@implementation SerialPort

/**
 *  打开串口
 *
 *  @param devName 通信设备在系统中的路径
 *  @param baudRate   打开串口时设置的波特率
 *
 *  @return 打开成功返回true，失败返回false
 */
- (Boolean)openPort:(NSString*)devName withBaudRate:(int)baudRate
{
    @autoreleasepool {
        NSString *devPath;
        struct termios termOpt;
//        DIR *d = opendir("/dev/");
//        if (!d)
//        {
//            //mermory leak
//            closedir(d);
//            return false;
//        }
//        struct dirent *dir;
//        while ( (dir = readdir(d)) != NULL)
//            if (strstr(dir->d_name, "cu.usb") && strstr(dir->d_name, [devName UTF8String]))
//                break;
//        if (!dir) {
//            //mermory leak
//            closedir(d);
//            return false;
//        }
//        
//        //mermory leak
//        closedir(d);
        
        devPath = [NSString stringWithFormat:@"/dev/cu.usb%@", devName];
        
        _fd = open([devPath cStringUsingEncoding:NSASCIIStringEncoding], O_RDWR | O_NONBLOCK | O_NOCTTY);
        
        if (_fd < 0)
        {
            /*insert debug log here*/;
            goto error;
        }
        
        if (tcgetattr(_fd, &termOpt) < 0)
        {
            //insert error log
            goto error;
        }
        
        termOpt.c_cflag &= ~(PARENB | CSTOPB);
        termOpt.c_iflag &= ~(ICRNL | INLCR);
        termOpt.c_oflag &= ~(OPOST | ONLCR | OCRNL);
        termOpt.c_lflag &= ~(ECHO | ECHOE | ECHOK | ECHONL | ICANON | ISIG);
        
        //子进程中继承的串口句柄在用exec执行新程序时被关闭
        int fdFlag = fcntl(_fd, F_GETFD, 0);
        fcntl(_fd, F_SETFD, fdFlag | FD_CLOEXEC);
        
        tcflush(_fd, TCIOFLUSH);
        
        if (tcsetattr(_fd, TCSANOW, &termOpt) < 0)
        {
            /*insert debug log here*/
            goto error;
        }
        
        if (false == [self setBaudRate:baudRate])
        {
            //insert error log
            goto error;
        }
    }
    return true;
error:
    /*error log*/;
    close(_fd);
    return false;
}

/**
 *  设置串口波特率的大小
 *
 *  @param baudRate 波特率数值
 *
 *  @return 设置成功返回true，失败返回false
 */
- (Boolean)setBaudRate:(int)baudRate
{
    const speed_t baudRatesDef[] = { B50, B75, B110, B134, B150, B200, B300, B600, B1200, B1800, B2400, B4800, B9600, B115200, B19200, B38400, B230400, B460800 };
    const int baudRates[] = { 50, 75, 110, 134, 150, 200, 300, 600, 1200, 1800, 2400, 4800, 9600, 115200, 19200, 38400, 230400, 460800 };

    int index, nlevels;
//    speed_t setSpeed;
    struct termios termOpt;

    nlevels = sizeof(baudRates);
    index = 0;
    while (baudRates[index] != baudRate && index < nlevels)
        index++;

    if (index == nlevels)
    {
        /*insert error log*/
        return false;
    }

    // Analyse Mark
//    setSpeed = baudRatesDef[index];
    
    if (tcgetattr(_fd, &termOpt) < 0)
    {
        /*insert log*/
        return false;
    }

    cfsetspeed(&termOpt, baudRatesDef[index]);
    
    tcflush(_fd, TCIOFLUSH);

    if (tcsetattr(_fd, TCSANOW, &termOpt) < 0)
    {
        /*insert log*/
        return false;
    }

    return true;
}

/**
 *  设置数据位大小
 *
 *  @param dataBits 数据位
 *
 *  @return 成功返回true，失败返回false
 */
- (Boolean)setDataBits:(enum DATABITS)dataBits
{
    struct termios termOpt;
    
    if (tcgetattr(_fd, &termOpt) < 0)
    {
        //error log
        return false;
    }

    termOpt.c_cflag &= ~(CSIZE);

    switch (dataBits)
    {
        case DATA5:
            termOpt.c_cflag |= (CS5);
            break;

        case DATA6:
            termOpt.c_cflag |= (CS6);
            break;

        case DATA7:
            termOpt.c_cflag |= (CS7);
            break;

        case DATA8:
        default:
            termOpt.c_cflag |= (CS8);
            break;
    }
    
    tcflush(_fd, TCIOFLUSH);

    if (tcsetattr(_fd, TCSANOW, &termOpt) < 0)
    {
        //insert log
        return false;
    }

    return true;
}

/**
 *  设置校验位
 *
 *  @param parityBits 校验位（奇校验，偶校验还是无校验）
 *
 *  @return 成功返回true，失败返回false
 */
- (Boolean)setParityBits:(enum PARITYBITS)parityBits
{
    struct termios termOpt;
    
    if (tcgetattr(_fd, &termOpt) < 0)
    {
        //insert log
        return false;
    }

    switch (parityBits)
    {
        case PAR_ODD:
            termOpt.c_cflag |= (PARENB);
            termOpt.c_cflag |= (PARODD);
            break;

        case PAR_EVEN:
            termOpt.c_cflag |= (PARENB);
            termOpt.c_cflag &= ~(PARODD);
            break;

        case PAR_NONE:
        default:
            termOpt.c_cflag &= ~(PARENB);
            break;
    }
    
    tcflush(_fd, TCIOFLUSH);

    if (tcsetattr(_fd, TCSANOW, &termOpt) < 0)
    {
        //insert log
        return false;
    }

    return true;
}

/**
 *  设置停止位
 *
 *  @param stopBits 停止位大小
 *
 *  @return 成功返回true，失败返回false
 */
- (Boolean)setStopBits:(enum STOPBITS)stopBits
{
    struct termios termOpt;
    
    if (tcgetattr(_fd, &termOpt) < 0)
    {
        //insert log
        return false;
    }

    switch (stopBits)
    {
        case STOP1:
        default:
            termOpt.c_cflag &= ~(CSTOPB);
            break;

        case STOP2:
            termOpt.c_cflag |= (CSTOPB);
            break;
    }
    
    tcflush(_fd, TCIOFLUSH);

    if (tcsetattr(_fd, TCSANOW, &termOpt) < 0)
    {
        //insert log
        return false;
    }

    return true;
}

- (Boolean)readData:(NSString* __autoreleasing*)recv inTime:(NSTimeInterval)timeOut endWith:(NSString*)endSign
{
    char recvBuf[BUFFSIZE];
    ssize_t nreads;
    NSDate* start;
    int foundEnd = 0;
    *recv = @"";
    
    self.stageData = [NSMutableData data];
    foundEnd = 0;
    
    int retryFlag = -1;
    
    for (int retry=0;retry<=2;retry++)
    {
        start = [NSDate date];
        NSTimeInterval currentTime = [start timeIntervalSinceNow] * -1;
    
        //在超时或遇到结尾符之前一直读取
      //  NSTimeInterval currentTime = [[NSDate date] timeIntervalSinceDate:start];
        while (currentTime < timeOut)
        {
//            usleep(500);
            NSData *appendData;
            nreads = read(_fd, recvBuf, BUFFSIZE-1);
            NSLog(@"%s:recvbuf(%s)", __FUNCTION__, recvBuf);
            if (nreads > 0)
            {
                recvBuf[nreads] = 0;
                appendData = [NSData dataWithBytes:recvBuf length:nreads];
                
                if (appendData)
                    [self.stageData appendData:appendData];
                
                if ([endSign length])
                {
                    *recv = [[NSString alloc] initWithData:self.stageData encoding:NSASCIIStringEncoding];
                    NSString * _tmp = [*recv stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    NSString * _endSignDelSpace = [endSign stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                    if ([_tmp hasSuffix:_endSignDelSpace])
                    //if ([_tmp rangeOfString:_endSignDelSpace].location != NSNotFound)
                    
                    NSString * cutStrTmp= @"";
                    if (_tmp.length > 23)
                    {
                        cutStrTmp = [_tmp substringFromIndex:(_tmp.length-23)];//判断最后23个字符是否包含endSymble
                    }
                    else
                    {
                        cutStrTmp = _tmp;
                    }
                    if ([cutStrTmp rangeOfString:_endSignDelSpace].location != NSNotFound)
                    {
                        foundEnd = 1;
                        break;
                    }
                }
            }
            
            currentTime = [start timeIntervalSinceNow] * -1;
        }
        NSString *temp = [[NSString alloc] initWithData:self.stageData encoding:NSASCIIStringEncoding];
        if ([temp rangeOfString:@"menu -"].location != NSNotFound)
        {
            NSLog(@"Found the 'menu -'");
            NSLog(@"Exception INFO : %@", temp);
            if (retryFlag == -1) {
                retryFlag = retry;
            } else if (retry - retryFlag >= 1) {
                break;
            }
        }
        else {
            break;
        }
    }
    
    *recv = [[NSString alloc] initWithData:self.stageData encoding:NSASCIIStringEncoding];
    
    if ([endSign length] && !foundEnd)
        return false;
    return true;
}

- (Boolean)writeData:(NSString*)sendData
{
//    tcflush(_fd, TCIOFLUSH);
    
//    NSData *data = [self dataFormHexString:sendData];
//    
//    NSMutableData *writeBuffer = [data mutableCopy];
//    while ([writeBuffer length] > 0)
//    {
//        long numBytesWritten = write(_fd, [writeBuffer bytes], [writeBuffer length]);
//        if (numBytesWritten < 0)
//        {
//            NSLog(@"Error writing to serial port:%d", errno);
//            return NO;
//        }
//        else if (numBytesWritten > 0)
//        {
//            [writeBuffer replaceBytesInRange:NSMakeRange(0, numBytesWritten) withBytes:NULL length:0];
//        }
//    }
    
//    Taylor Mark
    @autoreleasepool {
        size_t length;
        const void* csend;
        
        if ( (csend = [self _dataFromHexString:sendData dataLength:&length]) == NULL)   //写入字串，否则写入数据
        {
            sendData = [sendData stringByAppendingString:@"\r"];
            csend = [sendData cStringUsingEncoding:NSASCIIStringEncoding];
            length = [sendData length];
        }
        
        for (int i=0; i<length; i++)
        {
            if (write(_fd, csend + i, 1) != 1)
                return false;
            usleep(200);
        }
    }
    return true;
}

- (Boolean)writeDataWithTime:(NSString*)sendData
                     timeOut:(int)writeDataTimeOut;
{
    //    tcflush(_fd, TCIOFLUSH);
    
    //    NSData *data = [self dataFormHexString:sendData];
    //
    //    NSMutableData *writeBuffer = [data mutableCopy];
    //    while ([writeBuffer length] > 0)
    //    {
    //        long numBytesWritten = write(_fd, [writeBuffer bytes], [writeBuffer length]);
    //        if (numBytesWritten < 0)
    //        {
    //            NSLog(@"Error writing to serial port:%d", errno);
    //            return NO;
    //        }
    //        else if (numBytesWritten > 0)
    //        {
    //            [writeBuffer replaceBytesInRange:NSMakeRange(0, numBytesWritten) withBytes:NULL length:0];
    //        }
    //    }
    
    //    Taylor Mark
    @autoreleasepool {
        size_t length;
        const void* csend;
        
        if ( (csend = [self _dataFromHexString:sendData dataLength:&length]) == NULL)   //写入字串，否则写入数据
        {
            sendData = [sendData stringByAppendingString:@"\r"];
            csend = [sendData cStringUsingEncoding:NSASCIIStringEncoding];
            length = [sendData length];
        }
        
        for (int i=0; i<length; i++)
        {
            if (write(_fd, csend + i, 1) != 1)
                return false;
            usleep(writeDataTimeOut);
        }
    }
    return true;
}


- (NSData*)dataFormHexString:(NSString*)hexString{
    hexString=[[hexString uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!(hexString && [hexString length] > 0 && [hexString length]%2 == 0)) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

-(const void *)_dataFromHexString:(NSString *)hexStr dataLength:(size_t *)lenPtr
{
    if (hexStr.length <= 2)
        return NULL;
    if ([hexStr characterAtIndex:0] != '<' || [hexStr characterAtIndex:(hexStr.length-1)] != '>')
        return NULL;
    
    hexStr = [hexStr substringFromIndex:1]; //去除尖括号
    hexStr = [hexStr substringToIndex:(hexStr.length-1)];
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@" " withString:@""]; //去除空格
    
    NSData *temp = [self dataFormHexString:hexStr];
    *lenPtr = [temp length];
    return [temp bytes];
//    
//    NSString *pattern = @"^[a-fA-F\\d]+$";
//    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
//    NSTextCheckingResult *match = [regex firstMatchInString:hexStr options:0 range:NSMakeRange(0, hexStr.length)];
//    if (!match || hexStr.length%2 || hexStr.length > 2*(BUFSIZ-1))  //不符合十六进制数格式,不是整字节数，或数据过长
//        return NULL;
//    static unsigned char dataBuf[BUFSIZ];
//    memset(dataBuf, 0, BUFSIZ);
//    unsigned char *dataPtr = dataBuf;
//    while (hexStr.length) {
//        *dataPtr = [self __numberFromChar:[hexStr characterAtIndex:0]] << 4;
//        *dataPtr++ |= ([self __numberFromChar:[hexStr characterAtIndex:1]]);
//        hexStr = [hexStr substringFromIndex:2];
//    }
//    *dataPtr++ = '\r';
//    *lenPtr = dataPtr - dataBuf;
//    return dataBuf;
}

-(unsigned char)__numberFromChar:(char)uc
{
    if (uc >= '0' && uc <= '9')
        uc -= '0';
    if (uc >= 'a' && uc <= 'f')
        uc -= ('a' - 10);
    if (uc >= 'A' && uc <= 'F')
        uc -= ('A' - 10);
    return uc;
}

//-(Boolean)communicateWithCmd:(NSString*)cmd withinTime:(float)time endWith:(NSString*)endSympal getData:(NSString* __autoreleasing*)recv
//{
//    if([self writeData:cmd])
//        if ([self readData:recv inTime:time endWith:endSympal]) {
//            <#statements#>
//        }
//}
@end
