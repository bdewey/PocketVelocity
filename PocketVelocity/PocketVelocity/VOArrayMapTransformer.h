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

- (instancetype)initWithValueTransformer:(id<VOValueTransforming>)transformer
                expectsPipelineSemantics:(BOOL)expectsPipelineSemantics;
- (VOChangeDescribingArray *)transformValue:(VOChangeDescribingArray *)value;

@end

@interface VOTransformingPipelineStage (VOArrayMapTransformer)

- (VOTransformingPipelineStage *)pipelineWithArrayMappingBlock:(VOValueTransformingBlock)block;
- (VOTransformingPipelineStage *)pipelineWithArrayMappingTransformer:(id<VOValueTransforming>)transformer;

@end
