//
//  SocketViewController.h
//  ObjCSample
//
//  Created by Alexis Koopmann on 10/4/22.
//
//  Copyright © 2022 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface SocketViewController : UIViewController
- (void) onServerResponseUpdate:(NSNotification *)notification;

@property (weak, nonatomic) IBOutlet UITextField *server_response;
@property (weak, nonatomic) IBOutlet UIButton *send_button;
@property (weak, nonatomic) IBOutlet UILabel *connection_status;
@property (weak, nonatomic) IBOutlet UITextField *user_text;
@end

