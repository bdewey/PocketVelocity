//
//  PVUtilities.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/16/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE BOOL PVObjectsAreEqual(id<NSObject> object1, id<NSObject> object2)
{
  return (object1 == object2) || [object1 isEqual:object2];
}

NS_INLINE BOOL PVStringsAreEqual(NSString *string1, NSString *string2)
{
  return (string1 == string2) || [string1 isEqualToString:string2];
}

