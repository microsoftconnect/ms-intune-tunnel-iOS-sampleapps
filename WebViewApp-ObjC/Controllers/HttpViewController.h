//
//  HttpViewController.h
//  ObjCSample
// 
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface HttpViewController : UIViewController<UITextFieldDelegate, WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addressBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (strong, nonatomic) IBOutlet WKWebView *webview;
@property (strong, atomic) UIAlertController *credentialsPrompt;
@property(strong, nonatomic) UIActivityIndicatorView *indicatorView;
@end

