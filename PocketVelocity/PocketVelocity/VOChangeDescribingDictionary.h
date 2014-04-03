//
//  VOChangeDescribingDictionary.h
//  PocketVelocity
//
//  Created by Brian Dewey on 4/2/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOChangeDescribing.h"
#import "VODictionary.h"

@class VODictionaryChangeDescription;

@interface VOChangeDescribingDictionary : NSObject <NSCopying, NSMutableCopying, VOChangeDescribing, VODictionary>

@property (nonatomic, readonly, strong) VODictionaryChangeDescription *changeDescription;

- (instancetype)initWithValues:(NSDictionary *)values
             changeDescription:(VODictionaryChangeDescription *)changeDescription;

@end
