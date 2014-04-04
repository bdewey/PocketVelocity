//
//  PVMappedArray.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOBlockTransformer.h"
#import "VOChangeDescribingArray.h"
#import "VOTransformingPipelineStage.h"
#import "VOValueTransforming.h"

@interface VOArrayMapTransformer : NSObject <VOValueTransforming>

@property (nonatomic, readonly, assign) BOOL expectsPipelineSemantics;
@property (nonatomic, readonly, strong) id<VOValueTransforming> transformer;

- (instancetype)initWithValueTransformer:(id<VOValueTransforming>)transformer;
- (VOChangeDescribingArray *)transformValue:(VOChangeDescribingArray *)value previousResult:(VOChangeDescribingArray *)previousResult;

@end

@interface VOPipelineStage (VOArrayMapTransformer)

- (VOPipelineStage *)pipelineWithArrayMappingBlock:(VOValueTransformingBlock)block;
- (VOPipelineStage *)pipelineWithArrayMappingTransformer:(id<VOValueTransforming>)transformer;

@end
