//
//  SongMetaData.m
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-24.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

#import "SongMetaData.h"

@implementation SongMetaData

#pragma mark - Constructors

-(id)initWithMediaItem:(MPMediaItem *)item fromPeer:(MCPeerID *)peer
{
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	self.title = item.title;
	self.artist = item.artist;
	self.album = item.albumTitle;
	self.peerID = peer;
	self.duration = item.playbackDuration;
	return self;
}


#pragma mark - NSCoding Delegate Methods

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	self.title = [decoder decodeObjectForKey:@"title"];
	self.artist = [decoder decodeObjectForKey:@"artist"];
	self.album = [decoder decodeObjectForKey:@"album"];
	self.peerID = [decoder decodeObjectForKey:@"peerID"];
	self.duration = [decoder decodeDoubleForKey:@"duration"];

	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.title forKey:@"title"];
	[encoder encodeObject:self.artist forKey:@"artist"];
	[encoder encodeObject:self.album forKey:@"album"];
	[encoder encodeObject:self.peerID forKey:@"peerID"];
	[encoder encodeDouble:self.duration forKey:@"duration"];
}

+ (BOOL)supportsSecureCoding
{
	return YES;
}

@end
