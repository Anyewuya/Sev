//
//  ViewController.m
//  Client_stream
//
//  Created by TRY-MAC01 on 15-1-26.
//  Copyright (c) 2015年 ZH. All rights reserved.
//

#import "ViewController.h"
#define PORT 9000
@interface ViewController ()<NSStreamDelegate>
@property (nonatomic, assign) int flag;
@end

@implementation ViewController
@synthesize  flag;
- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)initNetWorkCommunication
{
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"10.0.0.36", PORT, &readStream, &writeStream);
    _inputStream = (__bridge_transfer NSInputStream *)readStream;
    _outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_inputStream open];
    
    [_outputStream open];

}


- (IBAction)sendData:(id)sender {
    flag = 0;
    [self initNetWorkCommunication];
}

- (IBAction)receiveData:(id)sender {
    flag = 1;
    [self initNetWorkCommunication];

}


- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    
    NSString *event;
    
    switch (eventCode) {
        case NSStreamEventNone:
            event = @"NSStreamEventNone";
            break;
        case NSStreamEventOpenCompleted:
            event = @"NSStreamEventOpenCompleted";
            break;
        case NSStreamEventHasBytesAvailable:
            event = @"NSStreamEventHasBytesAvailable";
            if (flag == 1 && aStream == _inputStream) {
                NSMutableData *input = [[NSMutableData alloc] init];
                uint8_t buffer[1024];
                int len;
                while ([_inputStream hasBytesAvailable]) {
                    len = [_inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        [input appendBytes:buffer length:len];
                    }
                }
                
                NSString *resultString = [[NSString alloc] initWithData:input encoding:NSUTF8StringEncoding];
                NSLog(@"接收：%@", resultString);
                _label.text = resultString;
                
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            event = @"NSStreamEventHasSpaceAvailable";
            if (flag == 0 && aStream == _outputStream) {
                UInt8 buff[] = "Hello Server---Sev";
                [_outputStream write:buff maxLength:strlen((const char *)buff) +1];
                [_outputStream close];
            }
            break;
        case NSStreamEventErrorOccurred:
            event =@"NSStreamEventErrorOccurred";
            break;
        case NSStreamEventEndEncountered:
            event = @"NSStreamEventEndEncountered";
            NSLog(@"Error:%ld:%@",(long)[[aStream streamError] code], [[aStream streamError] localizedDescription]);
            break;
        default:
            [self close];
            event = @"Unknown";
            break;
    }
    NSLog(@"event -----%@", event);
    
}

- (void)close
{
    [_outputStream close];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream setDelegate:nil];
    
    [_inputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream setDelegate:nil];

}

@end
