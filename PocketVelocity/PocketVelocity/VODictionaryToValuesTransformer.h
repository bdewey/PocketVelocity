//
//  VODictionaryToValuesTransformer.h
//  PocketVelocity
//
//  Created by Brian Dewey on 4/3/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOChangeDescribingArray.h"
#import "VOChangeDescribingDictionary.h"
#import "VOPipelineStage.h"
#import "VOValueTransforming.h"

@interface VODictionaryToValuesTransformer : NSObject <VOValueTransforming>

@property (nonatomic, readonly, strong) NSComparator comparator;

- (instancetype)initWithComparator:(NSComparator)comparator;

- (VOChangeDescribingArray *)transformValue:(VOChangeDescribingDictionary *)value
                             previousResult:(VOChangeDescribingArray *)previousResult;

@end

@interface VOPipelineStage (VODictionaryToValuesTransformer)

- (VOPipelineStage *)pipelineStageWithDictionaryToValuesWithComparator:(NSComparator)comparator;

@end