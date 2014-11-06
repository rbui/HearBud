//
//  SongTableViewCell.h
//  HearBud
//
//  Created by Ritchie Bui on 2014-11-06.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *playIndicator;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *artist;

@end
