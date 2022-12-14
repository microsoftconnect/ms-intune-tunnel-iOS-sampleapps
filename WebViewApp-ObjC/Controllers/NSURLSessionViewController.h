//
//  NSURLSessionViewController.h
//  ObjCSample
//
//  Created by Alexis Koopmann on 10/17/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSURLSessionViewController : UIViewController<NSURLSessionDelegate>
@property (weak, nonatomic) IBOutlet UILabel *response_data;
@property (weak, nonatomic) IBOutlet UIButton *trusted_button;
@property (weak, nonatomic) IBOutlet UIButton *untrusted_button;
@end

