//
//  SongMetaData.h
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-24.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

@import MediaPlayer;
@import MultipeerConnectivity;

@interface SongMetaData : NSObject <NSSecureCoding>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, assign) NSTimeInterval duration;

-(id)initWithMediaItem: (MPMediaItem *)item fromPeer:(MCPeerID *)peer;

@end
