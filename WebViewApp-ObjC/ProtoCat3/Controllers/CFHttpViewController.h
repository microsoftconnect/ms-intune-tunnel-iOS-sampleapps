//
//  CFHttpViewController.h
//  ProtoCat3
//
//  Created by Alexis Koopmann on 10/14/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CFHttpViewController : UIViewController<NSStreamDelegate>
@property (weak, nonatomic) IBOutlet UIButton *trusted_button;
@property (weak, nonatomic) IBOutlet UIButton *untrusted_button;
@property (weak, nonatomic) IBOutlet UILabel *response_data;
@end

NS_ASSUME_NONNULL_END
