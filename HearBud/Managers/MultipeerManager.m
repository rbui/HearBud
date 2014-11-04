//
//  MultipeerManager.m
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-21.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

@import AVFoundation;

#import "MultipeerManager.h"
#import "SongMetaData.h"
#import "TDAudioStreamer.h"
#import "AppDelegate.h"


#pragma mark - Class Variables

static MultipeerManager *_sharedInstance;


@interface MultipeerManager ()

@property (nonatomic, strong) TDAudioOutputStreamer *outputStreamer;
@property (nonatomic, strong) TDAudioInputStreamer *inputStreamer;
@property (nonatomic, strong) NSOutputStream *outStream;

-(void) sendSongListToPeers;

@end


@implementation MultipeerManager


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
	self.outStream = nil;

	_allSongsQuery = [[MPMediaQuery alloc] init];
	_songsToShare = [[NSMutableArray alloc] init];

	DLog(@"Will share %u songs", (unsigned int)[self.songsToShare count])
	return self;
}


#pragma mark - Public Multipeer Methods

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

#pragma mark - Public Send Song Data Methods

-(void) sendSongListToPeers
{
	NSData *songsData = [NSKeyedArchiver archivedDataWithRootObject: self.songsToShare];

	DLog(@"size of songlist to be sent is %lu", (unsigned long)songsData.length)
	
	if ([self.songsToShare count] > 0)
	{
		NSError *error;
		BOOL isSuccessful = [self.session sendData:songsData
										   toPeers:self.connectedDevices
										  withMode:MCSessionSendDataReliable
											 error:&error];

		if (!isSuccessful)
		{
			NSLog(@"%@", [error localizedDescription]);
		}
	}
}

-(void) sendSongRequestToPeer:(SongMetaData *)songData
{
	DLog(@"Sending request song reqest");
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject: songData];
	
	NSError *error;
	MultipeerManager *multiManager = [MultipeerManager sharedInstance];
	BOOL isSuccessful = [multiManager.session sendData:data
											   toPeers:@[songData.peerID]
											  withMode:MCSessionSendDataReliable
												 error:&error];
	
	if (!isSuccessful)
	{
		NSLog(@"%@", [error localizedDescription]);
	}
}


#pragma mark - Public Playback Methods

-(void)stopPlayback
{
	[self.inputStreamer stop];
}

-(void)resumePlayback
{
	[self.inputStreamer resume];
}

-(void)pausePlayback
{
	[self.inputStreamer pause];
}


#pragma mark - Private Methods

-(void)createListOfSongsToShare
{
	NSArray *queryResults = [self.allSongsQuery items];
	for (MPMediaItem *item in queryResults)
	{
		SongMetaData *songData = [[SongMetaData alloc] initWithMediaItem:item fromPeer:self.peerID];
		[self.songsToShare addObject: songData];
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
		DLog(@"%@ connected to %@", self.peerID, peerID);
		[self sendSongListToPeers];
	}
}


-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
	id receivedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	DLog(@"Data received class : %@", [receivedData class]);
	
	if ([receivedData isKindOfClass:[NSArray class]])
	{
		NSArray *songList = [[NSArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
		NSDictionary *dict = @{@"peerID": peerID,
							   @"songs" : songList
							   };
		[[NSNotificationCenter defaultCenter] postNotificationName:HBReceivedSongListNotificationKey
															object:nil
														  userInfo:dict];
	}
	else if ([receivedData isKindOfClass:[SongMetaData class]])
	{
		DLog(@"received song request");
		NSError *err;
		SongMetaData *songMetaData = receivedData;
		MPMediaItem *song = [self retrieveMediaForSongData: songMetaData];
		
		DLog(@"calling stop");
		[self.outputStreamer stop];
		self.outputStreamer = nil;
		DLog(@"stopped stream, starting new session stream");
		NSOutputStream *outStream = [self.session startStreamWithName:@"musicStream"
													toPeer:peerID
													 error:&err];
		if (!err)
		{
			self.outStream = outStream;
		}
		else
		{
			DLog(@"Error starting outstream %@", err.description);
		}
			
		self.outputStreamer = [[TDAudioOutputStreamer alloc]
							   initWithOutputStream:self.outStream];
		
		[self.outputStreamer streamAudioFromURL:[song valueForProperty:MPMediaItemPropertyAssetURL]];
		DLog(@"starting new outstream for song %@", song.title);
		[self.outputStreamer start];
		DLog(@"out stream started")
	}
}


-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
	
}


-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
	
}


-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
	DLog(@"received new stream named: %@", streamName);
	if ([streamName isEqualToString:@"musicStream"])
	{
		[self.inputStreamer stop];
		self.inputStreamer = nil;
		
		self.inputStreamer = [[TDAudioInputStreamer alloc] initWithInputStream:stream];
		DLog(@"starting new input stream");
		[self.inputStreamer start];
		DLog(@"input stream started");
	}
}

@end
