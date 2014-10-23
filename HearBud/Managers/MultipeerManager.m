//
//  MultipeerManager.m
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-21.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

#import "MultipeerManager.h"

static MultipeerManager *_sharedInstance;

@interface MultipeerManager ()

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


#pragma mark - MCSessionDelegate Methods

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
	NSDictionary *dict = @{@"peerID": peerID,
						   @"state" : [NSNumber numberWithInt:state]
						   };
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
														object:nil
													  userInfo:dict];
}


-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
	
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
