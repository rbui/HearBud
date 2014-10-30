//
//  OutStreamManager.h
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-29.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutStreamManager : NSObject

-(void)prepareAssetReaderFor:(MPMediaItem *)song;
-(void)prepareOutputStream: (NSOutputStream *)stream;
-(void)provideDataToStream;

+(OutStreamManager *) sharedInstance;


@end
