//
//  ProtocolTableViewController.m
//  ObjCSample
//
//  Created by Alexis Koopmann on 9/22/22.
//
//  Copyright © 2022 Microsoft. All rights reserved.
//

#import "ProtocolTableViewController.h"
#import "HttpViewController.h"
#include "MicrosoftTunnelDelegate.h"


@implementation ProtocolTableViewController {
    NSMutableArray<NSString*> *protocols;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    protocols = [NSMutableArray arrayWithObjects:@"Webview", @"Socket Echo",@"CFHTTP", @"URLSession", nil];
    MicrosoftTunnelStatus status = [[MicrosoftTunnelDelegate sharedDelegate] getStatus];
    switch (status) {
        case Uninitialized:
            [MicrosoftTunnelDelegate sharedDelegate];
        case Initialized:
        case Connected:
        case Disconnected:
            break;
        default:
        {
            NSString *errorMessage = [NSString stringWithFormat:@"Request attempted with invalid MicrosoftTunnel state: %@",
                                      [MicrosoftTunnelDelegate.sharedDelegate getStatusString]];
            [self showErrorAlert:@"Invalid State!" withMessage:errorMessage];
            return;
        }
    }
}

- (void) showErrorAlert:(NSString *) title withMessage:(NSString *) message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return protocols.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseIdentifier = protocols[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier
                                                            forIndexPath:indexPath];
    // Cell configuration
    cell.textLabel.text = protocols[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated:YES];
    
    // Any additional cell work goes here
}

@end
