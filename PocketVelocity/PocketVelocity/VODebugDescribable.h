//
//  VODebugDescribable.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/29/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VODebugDescribable <NSObject>

- (void)vo_describeInMutableString:(NSMutableString *)mutableString;

@end
