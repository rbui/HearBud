//
//  Common.h
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-23.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

#ifndef HearBud_Common_h
#define HearBud_Common_h


#endif

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif