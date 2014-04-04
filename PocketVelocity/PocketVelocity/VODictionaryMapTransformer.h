//
//  VODictionaryMapTransformer.h
//  PocketVelocity
//
//  Created by Brian Dewey on 4/3/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOBlockTransformer.h"
#import "VOPipelineStage.h"
#import "VOValueTransforming.h"

@interface VODictionaryMapTransformer : NSObject <VOValueTransforming>

@property (nonatomic, readonly, strong) id<VOValueTransforming> transformer;

- (instancetype)initWithValueTransformer:(id<VOValueTransforming>)transformer;

@end


@interface VOPipelineStage (VODictionaryMapTransformer)

- (VOPipelineStage *)pipelineWithDictionaryMappingBlock:(VOValueTransformingBlock)block;
- (VOPipelineStage *)pipelineWithDictionaryMappingTransformer:(id<VOValueTransforming>)transformer;

@end