//
//  NSURLSessionViewController.m
//  ProtoCat3
//
//  Created by Alexis Koopmann on 10/17/22.
//

#import "NSURLSessionViewController.h"
#import "Constants.h"

@implementation NSURLSessionViewController {
@public
    NSString *recv_string;
    NSError *error;
    NSURLResponse *recv_response;
@private
    NSString *url;
    NSInputStream *input;
    NSOutputStream *output;
    NSMutableArray *dataBuffer;
    int max_len;
}
- (IBAction)UntrustedHandler:(id)sender {
    NSLog(@"Making untrusted call. \n");
    [self makeCall:untrustedPage];
}
- (IBAction)TrustedHandler:(id)sender {
    NSLog(@"Making trusted call. \n");
    [self makeCall:trustedPage];
}
-(void)makeCall:(NSString*)url {
    self.trusted_button.enabled = false;
    self.untrusted_button.enabled = false;
    recv_string = nil;
    recv_response = nil;
    error = nil;
    NSURL *temp_url = [NSURL URLWithString:url];
    if (temp_url == nil){
        NSLog(@"Bad URL \n");
        [self.response_data setText:@"Bad URL \n"];
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:temp_url];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (error != nil) {
                NSLog(@"Read stream error occured %li: %@.", (long) error.code, error.localizedDescription);
                self->recv_string = [[NSString alloc] initWithString:error.localizedDescription];
            } else {
                self->recv_string = [[NSString alloc] initWithData:data encoding:kCFStringEncodingUTF8];
            }
            [self.response_data setText:self->recv_string];
            self.trusted_button.enabled = true;
            self.untrusted_button.enabled = true;
        });
    }];
    [dataTask resume];
}
@end
