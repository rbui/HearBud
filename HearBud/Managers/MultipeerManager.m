//
//  MultipeerManager.m
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-21.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

#import "MultipeerManager.h"
#import "Common.h"
#import "SongMetaData.h"


#pragma mark - Constants

static NSString *MMDidReceiveSongListNotificationKey = @"MMDidReceiveSongListNotification";
static NSString *MMDidReceiveSongRequestNotificationKey = @"MMCDidReceiveSongRequestNotification";


#pragma mark - Class Variables

static MultipeerManager *_sharedInstance;


@interface MultipeerManager ()

-(void) sendSongListToPeers;

@end


@implementation MultipeerManager

static NSString * const HBServiceType = @"hearbud-service";

#pragma mark - Properties



#pragma mark - Constructors

+ (void)initialize
{
	// Create a flag to keep track of whether or not this class has been initialized
	// because this method could be called a second time if a subclass does not override it.
	static BOOL classInitialized = NO;
	
	// If this class has not been initialized then create the shared instance.
	if (classInitialized == NO)
	{
		_sharedInstance = [[MultipeerManager alloc] init];
		
		classInitialized = YES;
	}
}

- (id)init
{
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	_peerID = nil;
	_session = nil;
	_browser = nil;
	_advertiser = nil;
	_connectedDevices = [[NSMutableArray alloc] init];

	_allSongsQuery = [[MPMediaQuery alloc] init];
	_songsToShare = [[NSMutableArray alloc] init];
	[self createListOfSongsToShare];
	
//	MPMediaQuery *allSongsQuery = [[MPMediaQuery alloc] init];
//	_songsToShare = [[NSMutableArray alloc] initWithArray: allSongsQuery.items];
	DLog(@"Will share %u songs", (unsigned int)[self.songsToShare count])
	return self;
}

#pragma mark - Public Methods

+ (MultipeerManager *) sharedInstance
{
	return _sharedInstance;
}

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName
{
	self.peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
	self.session = [[MCSession alloc] initWithPeer:self.peerID];
	self.session.delegate = self;
}

-(void)setupMCBrowser
{
	self.browser = [[MCBrowserViewController alloc]
					initWithServiceType:HBServiceType session:self.session];
}

-(void) advertiseSelf:(BOOL)shouldAdvertise
{
	if (shouldAdvertise)
	{
		self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:HBServiceType discoveryInfo:nil session:self.session];
		
		[self.advertiser start];
	}
	else
	{
		[self.advertiser stop];
		self.advertiser = nil;
	}
}

-(void)changeDisplayNameAndRestartSession:(NSString *)displayName
{
	self.advertiser = nil;
	[self setupPeerAndSessionWithDisplayName: displayName];
	[self setupMCBrowser];
}


-(void) sendSongListToPeers
{
	NSData *songsData = [NSKeyedArchiver archivedDataWithRootObject: self.songsToShare];

	DLog(@"size of songlist to be sent is %lu", (unsigned long)songsData.length)
	
	NSError *error;
	MultipeerManager *multiManager = [MultipeerManager sharedInstance];
	BOOL isSuccessful = [multiManager.session sendData:songsData
											   toPeers:multiManager.connectedDevices
											  withMode:MCSessionSendDataReliable
												 error:&error];

	if (!isSuccessful)
	{
		NSLog(@"%@", [error localizedDescription]);
	}
}


#pragma mark - Private Methods

-(void)createListOfSongsToShare
{
	NSArray *queryResults = [self.allSongsQuery items];
	for (MPMediaItem *item in queryResults)
	{
		SongMetaData *songData = [[SongMetaData alloc] initWithMediaItem:item];
		[self.songsToShare addObject: songData];
	}
}



#pragma mark - MCSessionDelegate Methods

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
	NSDictionary *dict = @{@"peerID": peerID,
						   @"state" : [NSNumber numberWithInt:state]
						   };
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
														object:nil
													  userInfo:dict];
	if (state == MCSessionStateConnected)
	{
		[self sendSongListToPeers];
	}
}


-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
	id receivedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	if ([receivedData isKindOfClass:[NSArray class]])
	{
		NSArray *songList = [[NSArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
		DLog(@"data received size is %lu", (unsigned long)data.length);
		//	DLog(@"song list dearchived count: %lu", [songList count]);
		NSDictionary *dict = @{@"peerID": peerID,
							   @"songs" : songList
							   };
		[[NSNotificationCenter defaultCenter] postNotificationName:MMDidReceiveSongListNotificationKey
															object:nil
														  userInfo:dict];
	}
	else if ([receivedData isKindOfClass:[SongMetaData class]])
	{
		SongMetaData *songMetaData = receivedData;
		
		// query for song
//		[[NSNotificationCenter defaultCenter] postNotificationName:MMDidReceiveSongRequestNotificationKey
//														  object:songMetaData];
		[self retrieveMediaForSongData: songMetaData];
	}
}

-(MPMediaItem *) retrieveMediaForSongData: (SongMetaData *) songData
{
	MPMediaPropertyPredicate *titlePredicate =
	[MPMediaPropertyPredicate predicateWithValue: songData.title
									 forProperty: MPMediaItemPropertyTitle];
	MPMediaPropertyPredicate *artistPredicate =
	[MPMediaPropertyPredicate predicateWithValue: songData.artist
									 forProperty: MPMediaItemPropertyArtist];
	MPMediaPropertyPredicate *albumPredicate =
	[MPMediaPropertyPredicate predicateWithValue: songData.album
									 forProperty: MPMediaItemPropertyAlbumTitle];
	NSSet *predicates =
	[NSSet setWithObjects: titlePredicate, artistPredicate, albumPredicate, nil];
	
	MPMediaQuery *mediaQuery = [[MPMediaQuery alloc] initWithFilterPredicates: predicates];
	NSArray *queryitems = [mediaQuery items];
	DLog(@"found song %@ matching request", ((MPMediaItem *)queryitems[0]).title);
	return queryitems[0];
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
	
}


-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
	
}


-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
	
}

@end
