//
//  ConnectionsViewController.h
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-21.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ConnectionsViewController : UIViewController
	<MCBrowserViewControllerDelegate,
	UITextFieldDelegate,
	UITableViewDelegate,
	UITableViewDataSource>


@end
