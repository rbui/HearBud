//
//  MultipeerManager.h
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-21.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

@import MediaPlayer;

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "SongMetaData.h"

static NSString *MMDidReceiveSongListNotificationKey;
static NSString *MMDidReceiveSongRequestNotificationKey;

@interface MultipeerManager : NSObject <MCSessionDelegate, NSStreamDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;
@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) NSMutableArray *connectedDevices;
@property (nonatomic, strong) NSMutableArray *songsToShare;
@property (nonatomic, strong) MPMediaQuery *allSongsQuery;

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;
-(void)setupMCBrowser;
-(void)advertiseSelf:(BOOL)shouldAdvertise;
-(void)changeDisplayNameAndRestartSession:(NSString *) displayName;
-(void)requestSongStream:(SongMetaData *) songData;

+(MultipeerManager *) sharedInstance;

@end
