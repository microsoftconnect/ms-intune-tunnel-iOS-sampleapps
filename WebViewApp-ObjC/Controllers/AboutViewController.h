//
//  AboutViewController.h
//  ObjCSample
//
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AboutViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *versionNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *microsoftTunnelStatus;
@property (weak, nonatomic) IBOutlet UIButton *microsoftTunnelButton;
@property (weak, nonatomic) IBOutlet UILabel *microsoftTunnelLabel;

- (void) onMicrosoftTunnelStatusChanged:(NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
