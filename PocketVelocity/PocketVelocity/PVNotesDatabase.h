//
//  PVNotesDatabase.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PVMutableListenableArray;

@interface PVNotesDatabase : NSObject

@property (nonatomic, readonly, copy) NSURL *directory;
@property (nonatomic, readonly, strong) PVMutableListenableArray *notes;

- (instancetype)initWithDirectory:(NSURL *)directory;

@end
