//
//  VODictionaryChangeDescription.h
//  PocketVelocity
//
//  Created by Brian Dewey on 4/2/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VODictionaryChangeDescription : NSObject

@property (nonatomic, readonly, copy) NSSet *insertedOrUpdatedKeys;
@property (nonatomic, readonly, copy) NSSet *removedKeys;

- (instancetype)initWithInsertedOrUpdatedKeys:(NSSet *)insertedOrUpdatedKeys removedKeys:(NSSet *)removedKeys;

@end
