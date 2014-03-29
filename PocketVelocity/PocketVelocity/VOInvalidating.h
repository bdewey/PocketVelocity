//
//  VOInvalidating.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/29/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VOInvalidating <NSObject>

@property (nonatomic, readonly, assign, getter = isValid) BOOL valid;
- (void)invalidate;

@end
