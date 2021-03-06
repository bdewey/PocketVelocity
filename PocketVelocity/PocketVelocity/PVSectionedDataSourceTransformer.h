//
//  PVSectionedDataSourceTransformer.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VOPipelineStage.h"
#import "VOValueTransforming.h"

@class PVSectionedDataSource;
@class VOChangeDescribingArray;

@interface PVSectionedDataSourceTransformer : NSObject <VOValueTransforming>

@property (nonatomic, readonly, assign) BOOL expectsPipelineSemantics;

- (instancetype)initWithPipelineSemantics:(BOOL)expectsPipelineSemantics;
- (PVSectionedDataSource *)transformValue:(VOChangeDescribingArray *)value previousResult:(PVSectionedDataSource *)previousResult;

@end

@interface VOPipelineStage (PVSectionedDataSourceTransformer)

- (VOPipelineStage *)pipelineTransformingToSectionedDataSource;

@end