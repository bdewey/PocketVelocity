//
//  VODictionaryFilterer.h
//  PocketVelocity
//
//  Created by Brian Dewey on 4/2/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOPipelineStage.h"
#import "VOValueTransforming.h"

typedef BOOL (^VODictionaryFiltererBlock)(id key, id value);

@interface VODictionaryFilterer : NSObject <VOValueTransforming>

@property (nonatomic, readonly, copy) VODictionaryFiltererBlock filterBlock;

- (instancetype)initWithFilterBlock:(VODictionaryFiltererBlock)filterBlock;

@end

@interface VOPipelineStage (VODictionaryFilterer)

- (VOPipelineStage *)pipelineByFilteringDictionaryWithBlock:(VODictionaryFiltererBlock)block;

@end
