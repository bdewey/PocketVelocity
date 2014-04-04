//
//  VOCoalescingPipelineStage.h
//  PocketVelocity
//
//  Created by Brian Dewey on 4/2/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOPipelineStage.h"

@class VOChangeDescribingDictionary;

@interface VOCoalescingPipelineStage : VOPipelineStage

@property (nonatomic, readonly, assign) NSTimeInterval coalescingTimeInterval;

- (instancetype)initWithSource:(id<VOPipelineSource>)source coalescingTimeInterval:(NSTimeInterval)coalescingTimeInterval;

- (void)pipelineSource:(id<VOPipelineSource>)pipelineSource didUpdateToValue:(VOChangeDescribingDictionary *)value;

@end

@interface VOPipelineStage (VOCoalescingPipelineStage)

- (VOPipelineStage *)pipelineStageCoalescedWithTimeInterval:(NSTimeInterval)timeInterval;

@end