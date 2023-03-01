//
//  AboutViewController.m
//  MSVPNTestApp
//
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//

#import <WebKit/WebKit.h>
#import "AboutViewController.h"
#include "MicrosoftTunnelDelegate.h"

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.versionNumberLabel.text = [[NSBundle.mainBundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.microsoftTunnelStatus.text = @"Uninitialized";
    [self updateVersionLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateLabel];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onMicrosoftTunnelStatusChanged:) name:kMicrosoftTunnelStatusUpdatedNotificationName object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (IBAction)handlePress:(id)sender {
    [self.microsoftTunnelButton setEnabled:NO];
    switch ([MicrosoftTunnelDelegate.sharedDelegate getStatus]) {
        case Initialized:
        case Disconnected:
            [MicrosoftTunnelDelegate.sharedDelegate connect];
            break;
        case Connected:
        case Reconnecting:
            [MicrosoftTunnelDelegate.sharedDelegate disconnect];
            break;
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
    self.microsoftTunnelLabel.text = [MicrosoftTunnelDelegate.sharedDelegate getVersionString];
}

- (void)updateLabel
{
    self.microsoftTunnelStatus.text = [MicrosoftTunnelDelegate.sharedDelegate getStatusString];
    switch ([MicrosoftTunnelDelegate.sharedDelegate getStatus]) {
        case Initialized:
        case Disconnected:
            [self.microsoftTunnelButton setTitle:@"Connect" forState:UIControlStateNormal];
            [self.microsoftTunnelButton setEnabled:YES];
            break;
        case Connected:
            [self.microsoftTunnelButton setTitle:@"Disconnect" forState:UIControlStateNormal];
            [self.microsoftTunnelButton setEnabled:YES];
            break;
        case Reconnecting:
            [self.microsoftTunnelButton setTitle:@"Disconnect" forState:UIControlStateNormal];
            [self.microsoftTunnelButton setEnabled:NO];
            break;
        default:
            [self.microsoftTunnelButton setTitle:@"Disabled" forState:UIControlStateDisabled];
            [self.microsoftTunnelButton setEnabled:NO];
            break;
    }
}

- (void)onMicrosoftTunnelStatusChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateLabel];
    });
}

@end
