//
//  ViewController.m
//  LYSocketServer
//
//  Created by hxf on 24/05/2017.
//  Copyright © 2017 sinowave. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"


@interface ViewController ()<GCDAsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *listenerPortTextField;
@property (weak, nonatomic) IBOutlet UITextField *messageBoardTextField;
- (IBAction)startListener:(id)sender;
- (IBAction)sendMessage:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *messageRecordBoard;

@property(nonatomic)GCDAsyncSocket *serverSocket;
@property(nonatomic)GCDAsyncSocket *clientSocket;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化Socket 设置delegate queue
    self.serverSocket =[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}

#pragma mark - GCDAsyncSocketDelegate
//收到客户端connect()
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    self.clientSocket = newSocket;
    
    self.messageRecordBoard.text = [NSString stringWithFormat:@"Ip:%@ Port:%i connect Success!\n",newSocket.connectedHost,newSocket.connectedPort];
    [self.clientSocket readDataWithTimeout:-1 tag:1];//(To not timeout, use a negative time interval.)
}

//收到客户端read()
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *receiveStr =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.messageRecordBoard.text = [self.messageRecordBoard.text stringByAppendingString:[NSString stringWithFormat:@"%@ \n",receiveStr]];
    [self.clientSocket readDataWithTimeout:-1 tag:1];//(To not timeout, use a negative time interval.)
}

#pragma mark -Events
- (IBAction)startListener:(id)sender
{
    [self.serverSocket disconnect];
    //监听port,Accept()
    NSError *err;
    [self.serverSocket acceptOnPort:self.listenerPortTextField.text.integerValue error:&err];
    if (err) {
        self.messageRecordBoard.text = [self.messageRecordBoard.text stringByAppendingString:[NSString stringWithFormat:@"%@ \n",err]];
    }
}

- (IBAction)sendMessage:(id)sender
{
    //发送数据
    [self.clientSocket writeData:[self.messageBoardTextField.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
