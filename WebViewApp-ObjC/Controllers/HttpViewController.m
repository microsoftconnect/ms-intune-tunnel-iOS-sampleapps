//
//  HttpViewController.m
//  ObjCSample
// 
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//

#import "HttpViewController.h"

@implementation HttpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupWebView];
    [self loadRequest:@"about:blank"];
    [self setupAddressBar];
}

#pragma mark Setup UI
- (void)setupWebView {
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    WKWebpagePreferences *preferences = [WKWebpagePreferences new];
    preferences.allowsContentJavaScript = YES;
    config.defaultWebpagePreferences = preferences;
    self.webview = [[WKWebView alloc] initWithFrame:CGRectZero configuration: config];
    self.webview.translatesAutoresizingMaskIntoConstraints = NO;
    self.webview.navigationDelegate = self;
    [self.view addSubview:self.webview];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    [self.indicatorView setCenter:self.view.center];
    [self.webview addSubview:self.indicatorView];
    [self setConstraints];
}
- (void)setupAddressBar {
    self.addressBar.delegate = self;
    self.addressBar.keyboardType = UIKeyboardTypeURL;
    self.addressBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.addressBar.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.addressBar.placeholder = @"Search your website";
}

- (void)setConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.webview.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.webview.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.webview.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.webview.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];
}

#pragma mark Private Methods
- (IBAction)refreshButtonClicked:(UIBarButtonItem *)sender {
    NSString* url = self.addressBar.text;
    [self loadRequest: url];
}

- (void) showErrorAlert:(NSString *) title withMessage:(NSString *) message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];

    [self presentViewController:alert animated:true completion:nil];
}

- (void)loadRequest:(NSString*)urlString {
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:90.0];
    [self.webview loadRequest:request];
}

#pragma mark TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ((self.addressBar == textField) && (textField.text.length != 0)) {
        [textField resignFirstResponder];
        NSString* url = textField.text;
        NSString* scheme = [[NSURL URLWithString:url] scheme];
        if (!scheme.length) {
            url = [NSString stringWithFormat:@"http://%@", url];
        }
        [self loadRequest:url];
    }
    return true;
}

#pragma mark WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    [self.indicatorView stopAnimating];
    NSHTTPURLResponse *response =(NSHTTPURLResponse*)[navigationResponse response];
    NSInteger statusCode =  response.statusCode;
    if (statusCode < 200 || statusCode > 400) {
        [self showErrorAlert:@"Request Error" withMessage: [NSString stringWithFormat:@"The request failed with status %ld", statusCode]];
         decisionHandler(WKNavigationResponsePolicyCancel);
    } else {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}
- (void) webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.indicatorView stopAnimating];
    [self showErrorAlert:@"Navigation Error" withMessage: [NSString stringWithFormat:@"The request failed with error %@", error.description ]];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self.indicatorView stopAnimating];
    [self showErrorAlert:@"Provisional Error" withMessage: [NSString stringWithFormat:@"The request failed with error %@", error.description ]];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.indicatorView stopAnimating];
    self.addressBar.text = [self.webview.URL absoluteString];
    
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.indicatorView startAnimating];
    self.addressBar.text = [self.webview.URL absoluteString];
}

- (void)webView:(WKWebView *)webView
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
                completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic] ||
        [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest] ||
        [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodNTLM])
    {
        [self promptUserForChallenge:challenge completionHandler:completionHandler];
    }
    else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
    else
    {
        NSLog(@"Unsupported auth method: %@ for protection space: %@:%ld",
              challenge.protectionSpace.authenticationMethod,
              challenge.protectionSpace.host,
              (long)challenge.protectionSpace.port);

        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)promptUserForChallenge:(NSURLAuthenticationChallenge *)challenge
             completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    if (self.credentialsPrompt)
    {
        NSLog(@"Prompt already showing, return");
        return;
    }

    self.credentialsPrompt = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Authorizing", @"Authorizing")
                                                                 message:[NSString stringWithFormat:@"Please enter you credentials for: %@",
                                                                          challenge.protectionSpace.authenticationMethod]
                                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *proceedAction;
    UIAlertAction *cancelAction;

    proceedAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSString *user = self.credentialsPrompt.textFields[0].text;
        NSString *password = self.credentialsPrompt.textFields[1].text;

        NSURLCredential *credential = [NSURLCredential credentialWithUser:user password:password persistence:NSURLCredentialPersistenceForSession];
        [self.credentialsPrompt dismissViewControllerAnimated:YES completion:^{
            self.credentialsPrompt = nil;
        }];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }];


    cancelAction = [UIAlertAction actionWithTitle: NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        NSLog(@"Cancel authentication");
        [self.credentialsPrompt dismissViewControllerAnimated:YES completion:^{
            self.credentialsPrompt = nil;
        }];
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }];

    [self.credentialsPrompt addAction:proceedAction];
    [self.credentialsPrompt addAction:cancelAction];
    [self.credentialsPrompt setPreferredAction:proceedAction];

    [self.credentialsPrompt addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Username", @"Username");
        if (challenge.proposedCredential != nil)
        {
            textField.text = challenge.proposedCredential.user;
        }
    }];

    [self.credentialsPrompt addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Password", @"Password");
        textField.secureTextEntry = YES;
        if (challenge.proposedCredential != nil)
        {
            textField.text = challenge.proposedCredential.password;
        }
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:self.credentialsPrompt animated:YES completion:nil];
    });
}
@end
