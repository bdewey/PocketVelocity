//
//  VOPipelineStage_Subclassing.h
//  PocketVelocity
//
//  Created by Brian Dewey on 4/1/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOPipelineStage.h"

@interface VOPipelineStage ()

- (id)transformValue:(id)value shouldContinueToSinks:(BOOL *)shouldContinueToSinks;

@end
