//
//  StreamManager.m
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-28.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

#import "StreamManager.h"


#pragma mark - Class Variables

static StreamManager *_sharedInstance;


@implementation StreamManager

#pragma mark - Constructors

+ (void)initialize
{
	static BOOL classInitialized = NO;

	if (classInitialized == NO)
	{
		_sharedInstance = [[StreamManager alloc] init];
		
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

+ (StreamManager *) sharedInstance
{
	return _sharedInstance;
}


@end
