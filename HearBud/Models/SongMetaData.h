//
//  SongMetaData.h
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-24.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

@import MediaPlayer;
#import <Foundation/Foundation.h>

@interface SongMetaData : NSObject <NSSecureCoding>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *album;

-(id)initWithMediaItem: (MPMediaItem *) item;

@end
