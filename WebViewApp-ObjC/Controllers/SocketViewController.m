//
//  SocketViewController.m
//  ObjCSample
//
//  Created by Alexis Koopmann on 10/4/22.
//
//  Copyright © 2022 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketViewController.h"
#import "EchoDelegate.h"

@implementation SocketViewController {
    EchoDelegate *echo_delegate;
}

- (void)viewDidLoad {
    echo_delegate = [EchoDelegate new];
    [echo_delegate initializeEchoDelegate];
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onServerResponseUpdate:) name:kServerResponseNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)onServerResponseUpdate:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateServerBox:[self->echo_delegate getServerResponse]];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateConnectionStatus:[self->echo_delegate getConnectionStatus]];
    });
}

-(void)updateServerBox:(NSString*)server_response{
    [_server_response setText:server_response];
}

-(void)updateConnectionStatus:(NSString*)connection_info{
    [_connection_status setText:connection_info];
}

- (IBAction)sendMessage:(id)sender {
    self.send_button.enabled = false;
    [echo_delegate setupNetworkConnection];
    NSString* user_text = [[NSString alloc] initWithString:self.user_text.text];
    NSLog(@"String being sent: %@", user_text);
    NSData *userData=[user_text dataUsingEncoding:NSUTF8StringEncoding];
    [echo_delegate sendMessage:userData];
    self.send_button.enabled = true;
}

@end
