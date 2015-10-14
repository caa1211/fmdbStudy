//
//  DatabaseManager.h
//  fmdbStudy
//
//  Created by Carter Chang on 10/14/15.
//  Copyright © 2015 Carter Chang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"

@interface DatabaseManager : NSObject
@property (nonatomic, strong) FMDatabaseQueue *queue;
+ (instancetype)sharedManager;
+ (NSNumber *) generateTimestamp;
@end
