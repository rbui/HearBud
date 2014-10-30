//
//  OutStreamManager.m
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-29.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

@import AVFoundation;
@import MediaPlayer;

#import "OutStreamManager.h"

@interface OutStreamManager ()


@property (nonatomic, strong) AVAssetReader *assetReader;
@property (nonatomic, strong) AVAssetReaderTrackOutput *assetOutput;
@property (nonatomic, strong) NSOutputStream *stream;

@end


#pragma mark - Class Variables

static OutStreamManager *_sharedInstance;


@implementation OutStreamManager

#pragma mark - Constructors

#pragma mark - Constructors

+ (void)initialize
{
	// Create a flag to keep track of whether or not this class has been initialized
	// because this method could be called a second time if a subclass does not override it.
	static BOOL classInitialized = NO;
	
	// If this class has not been initialized then create the shared instance.
	if (classInitialized == NO)
	{
		_sharedInstance = [[OutStreamManager alloc] init];
		
		classInitialized = YES;
	}
}

- (id)init
{
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	return self;
}


#pragma mark - Public Methods

+ (OutStreamManager *) sharedInstance
{
	return _sharedInstance;
}


-(void)prepareAssetReaderFor:(MPMediaItem *)song
{
	NSURL *mediaURL = [song valueForProperty:MPMediaItemPropertyAssetURL];
	AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mediaURL options:nil];
	AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:asset error:nil];
	self.assetOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:asset.tracks[0] outputSettings:nil];
	
	[assetReader addOutput:self.assetOutput];
	[assetReader startReading];
}

-(void)prepareOutputStream: (NSOutputStream *)stream
{
	self.stream = stream;
//	[self.stream setDelegate:self];
	[self.stream scheduleInRunLoop: [NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.stream open];
}

-(void)provideDataToStream
{
	CMSampleBufferRef sampleBuffer = [self.assetOutput copyNextSampleBuffer];
	CMBlockBufferRef blockBuffer;
	AudioBufferList audioBufferList;
	
	CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(AudioBufferList), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer);
	
	for (NSUInteger i = 0; i < audioBufferList.mNumberBuffers; i++)
	{
		AudioBuffer audioBuffer = audioBufferList.mBuffers[i];
		[self.stream write:audioBuffer.mData maxLength:audioBuffer.mDataByteSize];
	}
}


#pragma mark - NSStream Delegate Methods

-(void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	switch (eventCode) {
		case NSStreamEventHasBytesAvailable:
//			[self getDataFromStream];
			break;
			
		case NSStreamEventHasSpaceAvailable:
//			[[OutStreamManager sharedInstance] provideDataToStream];
			break;
			
		case NSStreamEventEndEncountered:
			
			break;
			
		case NSStreamEventErrorOccurred:
			
			break;
			
		default:
			break;
	}
	
}
@end
