//
//  VODictionary.h
//  PocketVelocity
//
//  Created by Brian Dewey on 4/2/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VODictionary <NSObject>

- (NSDictionary *)dictionary;
- (id)objectForKey:(id)key;
- (id)objectForKeyedSubscript:(id)key;
- (NSUInteger)count;

@end
