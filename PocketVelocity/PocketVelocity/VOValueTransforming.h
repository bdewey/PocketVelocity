//
//  VOValueTransforming.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/27/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VOValueTransforming <NSObject>

- (id)transformValue:(id)value previousResult:(id)previousResult;

@end
