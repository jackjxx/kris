//
//  foundUSB.m
//  CoreOSTool
//
//  Created by Gray on 2019/11/28.
//  Copyright © 2019 ASD. All rights reserved.
//

#import "foundUSB.h"
@implementation foundUSB

-(void)found_usb
{
    
//    CFNumberRef numberRef;
    mach_port_t masterPort;
    kern_return_t            kr;
    io_iterator_t            iter;
    
    _devices = [[NSMutableArray alloc] init];
    _device = [[NSMutableDictionary alloc] init];
    kr = IOMasterPort(MACH_PORT_NULL, &masterPort);

    
    _dict = IOServiceMatching(kIOUSBDeviceClassName);
    
    if (_dict == NULL) {
        NSLog(@"unable to create iokit dictionary");
    }
//    CFDictionarySetValue(_dict, CFSTR(kUSBProductStringIndex),@"iPad");

    kr = IOServiceGetMatchingServices(masterPort, _dict, &iter);
    [self GetUSBInterface:iter];
//    numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbVendor);

//    IOHIDManagerSetDeviceMatching(_hid_manager, _dict);
//
//    IOReturn ret = IOHIDManagerOpen(_hid_manager, kIOHIDOptionsTypeNone);
//
//    CFSetRef device_set = IOHIDManagerCopyDevices(_hid_manager);
//
//    int num_devices = (int)CFSetGetCount(device_set);
//
//    IOHIDDeviceRef device_list[256];
//    CFSetGetValue(device_set, (const void **)&device_list);
}
-(IOReturn)GetUSBInterface:(io_iterator_t) iterator
{
    kern_return_t            kr=0;
    io_service_t            usbDevice;
    IOCFPlugInInterface        **plugInInterface = NULL;
    IOUSBDeviceInterface    **dev = NULL;
    HRESULT                    result;
    SInt32                    score;
    UInt32                    locationID=0;
    UInt16                    relNum;
    while((usbDevice = IOIteratorNext(iterator))) {
        //Create an intermediate plug-in
        io_name_t   deviceName;

        kr = IORegistryEntryGetName(usbDevice, deviceName);

        NSString* devName = [NSString stringWithUTF8String:deviceName];
        
        kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID,
                                                                    kIOCFPlugInInterfaceID, &plugInInterface, &score);
        //Don't need the device object after intermediate plug-in is created
        kr = IOObjectRelease(usbDevice);
        if(kr != kIOReturnSuccess || !plugInInterface) {
            printf("Unable to create a plug-in (%08x)\n", kr);
            continue;
        }
        //Now create the device interface
        result = (*plugInInterface)->QueryInterface(plugInInterface,
                                                                                CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), (LPVOID *)&dev);
        //Don't need the device object after intermediate plug-in is created
        IODestroyPlugInInterface(plugInInterface);
        if(result || !dev) {
            printf("Unable to create a device interface (%08x)\n",(int)result);
            continue;
        }
       //Check these values for confirmation

        if ([devName isEqualToString:@"iPad"]) {
            NSString * serialNumber;
            CFTypeRef platformSerialNumber = IORegistryEntryCreateCFProperty(usbDevice, CFSTR(kUSBSerialNumberString), kCFAllocatorDefault, 0);
            if (CFGetTypeID(platformSerialNumber) == CFStringGetTypeID())
            {
                
                serialNumber = [NSString stringWithString:(__bridge NSString*)platformSerialNumber];
                
                CFRelease(platformSerialNumber);
            }
            kr = (*dev)->GetLocationID(dev, &locationID);
            kr = (*dev)->GetDeviceReleaseNumber(dev, &relNum);
            
            NSString* location = [NSString stringWithFormat:@"0x%08X",locationID];
            NSString* relNumX = [NSString stringWithFormat:@"%04X",relNum];
            NSString* relNumD = [NSString stringWithFormat:@"%.2f",[relNumX floatValue]/100];
            
            _device = [[NSMutableDictionary alloc] init];
            [_device setObject:devName forKey:@"devname"];
            [_device setObject:location forKey:@"locationID"];
            [_device setObject:serialNumber forKey:@"serialNumber"];
            [_device setObject:relNumD forKey:@"version"];
            
            [_devices addObject:_device];
//            [_locationIDs addObject:[NSString stringWithFormat:@"0x%08X",locationID]];
        }
    }
    return kr;
}

@end
