//
//  VOMutableChangeDescribingDictionary.h
//  PocketVelocity
//
//  Created by Brian Dewey on 4/2/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOChangeDescribing.h"
#import "VODictionary.h"

@class VODictionaryChangeDescription;

@interface VOMutableChangeDescribingDictionary : NSObject <NSCopying, NSMutableCopying, VOChangeDescribing, VODictionary>

@property (nonatomic, readonly, copy) id<NSCopying, VODictionary> originalValues;
@property (nonatomic, readonly, strong) VODictionaryChangeDescription *changeDescription;

- (instancetype)initWithOriginalValues:(id<NSCopying, VODictionary>)originalValues;

- (void)setObject:(id)object forKey:(id<NSCopying>)key;
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;
- (void)removeObjectForKey:(id<NSCopying>)key;

@end
