//
//  PVMappedArray.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVListenableArray.h"

typedef id (^PVMappedArrayMappingBlock)(id object);

@interface PVMappedArray : PVListenableArray

- (instancetype)initWithSourceArray:(PVListenableArray *)source mappingBlock:(PVMappedArrayMappingBlock)block;

@property (nonatomic, readonly, strong) PVListenableArray *source;

@end

@interface PVListenableArray (PVMappedArray)

- (PVMappedArray *)mappedArrayWithMappingBlock:(PVMappedArrayMappingBlock)mappingBlock;

@end
