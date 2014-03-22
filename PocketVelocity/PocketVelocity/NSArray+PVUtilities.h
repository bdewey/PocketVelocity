//
//  NSArray+PVUtilities.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/16/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^PVUtilityMapBlock)(id object, BOOL *stop);

@interface NSArray (PVUtilities)

- (NSArray *)pv_mapWithBlock:(PVUtilityMapBlock)block;

@end
