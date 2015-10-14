//
//  SoppingGuideDB.h
//  fmdbStudy
//
//  Created by Carter Chang on 10/14/15.
//  Copyright © 2015 Carter Chang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoppingGuideDB : NSObject

+(void) getAllFavoriteLists;
+(void) createFavoriteListWithName:(NSString*)name;
+(void) deleteFavoriteListById:(NSInteger)id;


@end
