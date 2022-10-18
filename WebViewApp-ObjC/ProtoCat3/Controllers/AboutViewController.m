//
//  AboutViewController.m
//  MSVPNTestApp
//
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//

#import <WebKit/WebKit.h>
#import "AboutViewController.h"
#include "MobileAccessDelegate.h"

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.versionNumberLabel.text = [[NSBundle.mainBundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.mobileAccessStatus.text = @"Uninitialized";
    [self updateVersionLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateLabel];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onMobileAccessStatusChanged:) name:kMobileAccessStatusUpdatedNotificationName object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (IBAction)handlePress:(id)sender {
    [self.mobileAccessButton setEnabled:NO];
    switch ([MobileAccessDelegate.sharedDelegate getStatus]) {
        case Initialized:
        case Disconnected:
            [MobileAccessDelegate.sharedDelegate connect];
            break;
        case Connected:
        case Reconnecting:
            [MobileAccessDelegate.sharedDelegate disconnect];
        default: // We should never be here, throw
            NSLog(@"Error unexpected state!\n");
            @throw NSInternalInconsistencyException;
            break;
    }
}

- (IBAction)handleClearCachePress:(id)sender {
    NSSet <NSString *> *websiteDataTypes = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]];
    NSDate *clearDate = [NSDate dateWithTimeIntervalSince1970:0];
    [WKWebsiteDataStore.defaultDataStore removeDataOfTypes:websiteDataTypes modifiedSince:clearDate completionHandler: ^(){}];
}

- (void)updateVersionLabel
{
    self.mobileAccessLabel.text = [MobileAccessDelegate.sharedDelegate getVersionString];
}

- (void)updateLabel
{
    self.mobileAccessStatus.text = [MobileAccessDelegate.sharedDelegate getStatusString];
    switch ([MobileAccessDelegate.sharedDelegate getStatus]) {
        case Initialized:
        case Disconnected:
            [self.mobileAccessButton setTitle:@"Connect" forState:UIControlStateNormal];
            break;
        case Connected:
        case Reconnecting:
            [self.mobileAccessButton setTitle:@"Disconnect" forState:UIControlStateNormal];
            break;
        default:
            [self.mobileAccessButton setTitle:@"Disabled" forState:UIControlStateDisabled];
            [self.mobileAccessButton setEnabled:NO];
            break;
    }
}

- (void)onMobileAccessStatusChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateLabel];
    });
}

@end
