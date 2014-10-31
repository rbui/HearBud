//
//  InStreamManager.m
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-29.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

@import AVFoundation;
#import "InStreamManager.h"


#pragma mark - Class Variables

static InStreamManager *_sharedInstance;

@interface InStreamManager ()

@property (nonatomic, strong) NSInputStream *stream;
@property (nonatomic) AudioFileStreamID inAudioFileStreamID;

@end


void audioQueueOutputCallback(void *inUserData, AudioQueueRef inAudioQueue, AudioQueueBufferRef inAudioQueueBuffer)
{
	InStreamManager *inStreamManager = (__bridge InStreamManager *)inUserData;
//	[inStreamManager didFreeAudioQueueBuffer:inAudioQueueBuffer];
}

@implementation InStreamManager

#pragma mark - Constructors

+ (void)initialize
{
	// Create a flag to keep track of whether or not this class has been initialized
	// because this method could be called a second time if a subclass does not override it.
	static BOOL classInitialized = NO;
	
	// If this class has not been initialized then create the shared instance.
	if (classInitialized == NO)
	{
		_sharedInstance = [[InStreamManager alloc] init];
		
		classInitialized = YES;
	}
}

- (id)init
{
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	AudioFileStreamID audioFileStreamID;
	OSStatus err = AudioFileStreamOpen((__bridge void *)self, AudioFileStreamPropertyListener, AudioFileStreamPacketsListener, 0, &audioFileStreamID);
	
	if (err)
	{
		return nil;
	}
	
	return self;
}


#pragma mark - Public Methods

+ (InStreamManager *) sharedInstance
{
	return _sharedInstance;
}


#pragma mark - Private Methods

-(void) getDataFromStream
{
	uint8_t data[512];
	UInt32 length = (UInt32)[self.stream read:data maxLength:512];
	
	OSStatus err = AudioFileStreamParseBytes(self.inAudioFileStreamID, length, data, 0);
	if (err)
	{
		
	}
}

- (void)didReceivePackets:(const void *)packets packetDescriptions:(AudioStreamPacketDescription *)packetDescriptions numberOfPackets:(UInt32)numberOfPackets numberOfBytes:(UInt32)numberOfBytes
{
	if (packetDescriptions) {
//		for (NSUInteger i = 0; i < numberOfPackets; i++) {
//			SInt64 packetOffset = packetDescriptions[i].mStartOffset;
//			UInt32 packetSize = packetDescriptions[i].mDataByteSize;
//			
//			[self.delegate audioFileStream:self didReceiveData:(const void *)(packets + packetOffset) length:packetSize packetDescription:(AudioStreamPacketDescription)packetDescriptions[i]];
//		}
//	} else {
//		[self.delegate audioFileStream:self didReceiveData:(const void *)packets length:numberOfBytes];
	}
}

void AudioFileStreamPropertyListener(void *inClientData, AudioFileStreamID inAudioFileStreamID, AudioFileStreamPropertyID inPropertyID, UInt32 *ioFlags)
{
	InStreamManager *inStreamManager = (__bridge InStreamManager *)inClientData;
	[inStreamManager didChangeProperty:inPropertyID flags:ioFlags audioFileStreamID:inAudioFileStreamID];
}

void AudioFileStreamPacketsListener(void *inClientData, UInt32 inNumberBytes, UInt32 inNumberPackets, const void *inInputData, AudioStreamPacketDescription *inPacketDescriptions)
{
	InStreamManager *inStreamManager = (__bridge InStreamManager *)inClientData;
	[inStreamManager didReceivePackets:inInputData packetDescriptions:inPacketDescriptions numberOfPackets:inNumberPackets numberOfBytes:inNumberBytes];
}

- (void)didChangeProperty:(AudioFileStreamPropertyID)propertyID flags:(UInt32 *)flags audioFileStreamID:(AudioFileStreamID) audioFileStreamID
{
	if (propertyID == kAudioFileStreamProperty_ReadyToProducePackets) {
		AudioStreamBasicDescription basicDescription;
		UInt32 basicDescriptionSize = sizeof(basicDescription);
		AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_DataFormat, &basicDescriptionSize, &basicDescription);
	}
}

-(void) setupAudioQueueForStreamDescription:(AudioStreamBasicDescription) basicDescription
{
	AudioQueueRef audioQueue;
	AudioQueueNewOutput(&basicDescription, audioQueueOutputCallback, (__bridge void *)self, NULL, NULL, 0, &audioQueue);
	
	AudioQueueBufferRef audioQueueBuffer;
	AudioQueueAllocateBuffer(audioQueue, 2048, &audioQueueBuffer);
}


#pragma mark - Audio Queue Events

- (void)didFreeAudioQueueBuffer:(AudioQueueBufferRef)audioQueueBuffer
{
//	[self.bufferManager freeAudioQueueBuffer:audioQueueBuffer];
//	
//	[self.waitForFreeBufferCondition lock];
//	[self.waitForFreeBufferCondition signal];
//	[self.waitForFreeBufferCondition unlock];
//	
//	if (self.state == TDAudioQueueStateStopped && ![self.bufferManager isProcessingAudioQueueBuffer]) {
//		[self.delegate audioQueueDidFinishPlaying:self];
//	}
}


#pragma mark - NSStream Delegate Methods

-(void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	switch (eventCode) {
		case NSStreamEventHasBytesAvailable:
			[self getDataFromStream];
			break;
			
		case NSStreamEventHasSpaceAvailable:
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
