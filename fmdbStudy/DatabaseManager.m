//
//  DatabaseManager.m
//  fmdbStudy
//
//  Created by Carter Chang on 10/14/15.
//  Copyright © 2015 Carter Chang. All rights reserved.
//

#import "DatabaseManager.h"

@implementation DatabaseManager
+ (instancetype)sharedManager
{
    static id sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsPath = [paths objectAtIndex:0];
        NSString *path = [docsPath stringByAppendingPathComponent:@"shoppingGuide.sqlite"];
        _queue = [[FMDatabaseQueue alloc] initWithPath:path];
    }
    return self;
}

+ (NSNumber *) generateTimestamp {
    return [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
}

@end
