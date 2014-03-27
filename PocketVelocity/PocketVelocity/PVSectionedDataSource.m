//
//  PVSectionedDataSource.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVArrayChangeDescription.h"
#import "PVSectionedDataSource.h"
#import "VOChangeDescribingArray.h"
#import "PVListenersCollection.h"

@interface PVSectionedDataSource () <PVListening>
@end

@interface PVSectionedDataSourceChangeDescription ()
- (instancetype)initWithInsertedIndexPaths:(NSArray *)insertedIndexPaths removedIndexPaths:(NSArray *)removedIndexPaths;
@end

@implementation PVSectionedDataSource
{
  NSArray *_sectionDataSources;
  PVListenersCollection *_listeners;
}

- (instancetype)initWithSections:(NSArray *)sectionDataSources
{
  self = [super init];
  if (self != nil) {
    _listeners = [[PVListenersCollection alloc] init];
    _sectionDataSources = [sectionDataSources copy];
  }
  return self;
}

#pragma mark - Public API

- (NSUInteger)countOfSections
{
  return _sectionDataSources.count;
}

- (NSUInteger)countOfItemsInSection:(NSUInteger)section
{
  return [_sectionDataSources[section] count];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
  return _sectionDataSources[indexPath.section][indexPath.row];
}

- (NSArray *)objectsAtIndexPaths:(NSArray *)indexPaths {
  NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:indexPaths.count];
  for (NSIndexPath *indexPath in indexPaths) {
    [results addObject:[self objectAtIndexPath:indexPath]];
  }
  return results;
}


#pragma mark - PVListenable

- (void)addListener:(id<PVListening>)observer
{
  [_listeners addListener:observer];
}

- (void)removeListener:(id<PVListening>)observer
{
  [_listeners removeListener:observer];
}

#pragma mark - PVListening

- (void)listenableObject:(VOChangeDescribingArray *)array didChangeWithDescription:(PVArrayChangeDescription *)delta
{
  NSUInteger section = [_sectionDataSources indexOfObject:array];
  NSMutableArray *insertedIndexPaths = [[NSMutableArray alloc] initWithCapacity:delta.indexesToAddFromUpdatedValues.count];
  [delta.indexesToAddFromUpdatedValues enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
    [insertedIndexPaths addObject:indexPath];
  }];
  NSMutableArray *removedIndexPaths = [[NSMutableArray alloc] initWithCapacity:delta.indexesToRemoveFromOldValues.count];
  [delta.indexesToRemoveFromOldValues enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
    [removedIndexPaths addObject:indexPath];
  }];
  PVSectionedDataSourceChangeDescription *changeDescription = [[PVSectionedDataSourceChangeDescription alloc] initWithInsertedIndexPaths:insertedIndexPaths
                                                                                                                       removedIndexPaths:removedIndexPaths];
  [_listeners listenableObject:self didChangeWithDescription:changeDescription];
}

@end

@implementation PVSectionedDataSourceChangeDescription

- (instancetype)initWithInsertedIndexPaths:(NSArray *)insertedIndexPaths removedIndexPaths:(NSArray *)removedIndexPaths
{
  self = [super init];
  if (self != nil) {
    _insertedIndexPaths = [insertedIndexPaths copy];
    _removedIndexPaths = [removedIndexPaths copy];
  }
  return self;
}

@end

@implementation VOChangeDescribingArray (PVSectionedDataSource)

- (PVSectionedDataSource *)sectionedDataSource
{
  return [[PVSectionedDataSource alloc] initWithSections:@[self]];
}

@end