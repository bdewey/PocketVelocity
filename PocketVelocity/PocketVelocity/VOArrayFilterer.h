//
//  VOArrayFilterer.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOPipeline.h"
#import "VOBlockTransformer.h"
#import "VOValueTransforming.h"

@class VOChangeDescribingArray;

typedef BOOL (^VOArrayFilterValidationBlock)(VOChangeDescribingArray *currentValue);

@interface VOArrayFilterer : NSObject <VOValueTransforming>

@property (nonatomic, readonly, strong) id<VOValueTransforming> transformer;
@property (nonatomic, readonly, assign) BOOL expectsPipelineSemantics;

- (instancetype)initWithTransformer:(id<VOValueTransforming>)transformer
           expectsPipelineSemantics:(BOOL)expectsPipelineSemantics
                    validationBlock:(VOArrayFilterValidationBlock)validationBlock;

- (instancetype)initWithTransformer:(id<VOValueTransforming>)transformer
           expectsPipelineSemantics:(BOOL)expectsPipelineSemantics;
- (VOChangeDescribingArray *)transformValue:(VOChangeDescribingArray *)value;

@end

@interface VOPipeline (VOArrayFilterer)

- (VOPipeline *)pipelineWithArrayFilteringBlock:(VOValueTransformingBlock)block;
- (VOPipeline *)pipelineWithArrayFilteringTransformer:(id<VOValueTransforming>)transformer;

@end
