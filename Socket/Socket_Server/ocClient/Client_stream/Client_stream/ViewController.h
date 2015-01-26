//
//  ViewController.h
//  Client_stream
//
//  Created by TRY-MAC01 on 15-1-26.
//  Copyright (c) 2015年 ZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sys/socket.h>
#include <netinet/in.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *send;

@property (weak, nonatomic) IBOutlet UIButton *accept;



@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;

- (IBAction)sendData:(id)sender;
- (IBAction)receiveData:(id)sender;

@end

