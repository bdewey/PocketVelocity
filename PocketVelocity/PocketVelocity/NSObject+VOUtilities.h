//
//  NSObject+VOUtilities.h
//  PocketVelocity
//
//  Created by Brian Dewey on 4/3/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSNULL_IF_NIL(obj)  ((obj==nil)?[NSNull null]:obj)

@interface NSObject (VOUtilities)

- (NSString *)vo_descriptionWithProperties:(NSDictionary *)properties;

@end
