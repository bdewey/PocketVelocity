//
//  VOTestUtilities.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/31/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOTestUtilities.h"

@implementation VOTestUtilities

+ (BOOL)runRunLoopUntilCondition:(BOOL *)condition
{
  CFTimeInterval tick = 0.01;
  CFTimeInterval timeoutDate = CACurrentMediaTime() + 5;
  while (!*condition) {
    if (CACurrentMediaTime() > timeoutDate) {
      break;
    }
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, tick, true);
  }
  return *condition;
}

@end
