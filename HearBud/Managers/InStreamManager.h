//
//  InStreamManager.h
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-29.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InStreamManager : NSObject <NSStreamDelegate>

+(InStreamManager *) sharedInstance;

@end
