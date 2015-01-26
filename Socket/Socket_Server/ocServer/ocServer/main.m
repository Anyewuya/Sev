//
//  main.m
//  ocServer
//
//  Created by TRY-MAC01 on 15-1-26.
//  Copyright (c) 2015年 ZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define PORT 9000

void AcceptCallBack(CFSocketRef, CFSocketCallBackType, CFDataRef, const void *, void *);
void WriteStreamClientCallBack(CFWriteStreamRef stream, CFStreamEventType eventType, void *);
void ReadStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType eventType, void *);
typedef void (* CFSocketCallBack)(
    CFSocketRef s,
    CFSocketCallBackType callbackType,
    CFDataRef address,
    const void *data,

    void *info
);

typedef void (* CFWriteStreamClientCallBack)(
    CFWriteStreamRef stream,
    CFStreamEventType eventType,
    void *clientCallBackInfo
);

typedef void (* CFReadStreamClientCallBack)(
    CFReadStreamRef stream,
    CFStreamEventType eventType,
    void *clientCallBackInfo
);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        CFSocketRef sserver;
        
        CFSocketContext CTX = {0, NULL, NULL, NULL, NULL};
        sserver = CFSocketCreate(NULL, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)AcceptCallBack, &CTX);
        
        if (sserver == NULL) {
            NSLog(@"sserver is %@", sserver);
            return -1;
        }
        int yes = 1;
        
        setsockopt(CFSocketGetNative(sserver), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
        struct sockaddr_in addr;
        memset(&addr, 0, sizeof(addr));
        addr.sin_len = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_port = htons(PORT);
        addr.sin_addr.s_addr = htonl(INADDR_ANY);
        
        CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr, sizeof(addr));
        
        if (CFSocketSetAddress(sserver, (CFDataRef)address) != kCFSocketSuccess) {
            fprintf(stderr, "Socket bind shibai");
            CFRelease(sserver);
            return -1;
        }
        
        CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, sserver, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), sourceRef, kCFRunLoopCommonModes);
        CFRelease(sourceRef);
        
        printf("Socket listening on port %d\n", PORT);
        CFRunLoopRun();
        
        
    }
    return 0;
}

void AcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    
    CFSocketNativeHandle sock = *(CFSocketNativeHandle *)data;
    
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, sock, &readStream, &writeStream);
    if (!readStream || !writeStream) {
        close(sock);
        fprintf(stderr, "CFStreamCreatePairWithSocket() shibai\n");
        return;
    }
    CFStreamClientContext streamCtxt = {0, NULL, NULL, NULL, NULL};
    CFReadStreamSetClient(readStream, kCFStreamEventHasBytesAvailable, ReadStreamClientCallBack, &streamCtxt);
    CFWriteStreamSetClient(writeStream, kCFStreamEventCanAcceptBytes, WriteStreamClientCallBack, &streamCtxt);
    
    
    CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    
    CFReadStreamOpen(readStream);
    CFWriteStreamOpen(writeStream);
}
UInt8 tmp[255];
void ReadStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo)
{
    UInt8 buff[255];
    CFReadStreamRef inputStream = stream;
    
    if (NULL != inputStream) {
        CFReadStreamRead(stream, buff, 255);
        for (int i = 0; i < 15; i++) {
            tmp[i] = buff[i];
        }
        printf("接收数据:%s \n",buff);
        CFReadStreamClose(inputStream);
        CFReadStreamUnscheduleFromRunLoop(inputStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        inputStream = NULL;
    }
}

void WriteStreamClientCallBack(CFWriteStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo)
{
    CFWriteStreamRef outputStream = stream;
    
    UInt8 buff[] ="Client";
    
    if (NULL != outputStream) {
        CFWriteStreamWrite(outputStream, buff, strlen((const char *)buff + 1));
        CFWriteStreamWrite(outputStream, tmp, strlen((const char *)tmp +1));
        CFWriteStreamClose(outputStream);
        CFWriteStreamUnscheduleFromRunLoop(outputStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        outputStream = NULL;
    }
}

CFIndex CFReadStreamRead(
    CFReadStreamRef stream,
    UInt8 *buffer,
    CFIndex bufferLength
);


CFIndex CFWriteStreamWrite(
    CFWriteStreamRef stream,
    const UInt8 *buffer,
    CFIndex bufferLength
);
