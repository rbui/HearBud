//
//  FirstViewController.h
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-21.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController
	<MPMediaPickerControllerDelegate,
	UITableViewDataSource,
	UITableViewDelegate>

@property (nonatomic) NSMutableArray *songs;

@end

