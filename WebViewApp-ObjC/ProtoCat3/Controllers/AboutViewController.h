//
//  AboutViewController.h
//  ProtoCat3
//
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AboutViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *versionNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileAccessStatus;
@property (weak, nonatomic) IBOutlet UIButton *mobileAccessButton;
@property (weak, nonatomic) IBOutlet UILabel *mobileAccessLabel;

- (void) onMobileAccessStatusChanged:(NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
