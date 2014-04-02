//
//  PVSectionedDataSource.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "NSIndexSet+PVUtilities.h"
#import "PVSectionedDataSource.h"
#import "VOArrayChangeDescription.h"
#import "VOChangeDescribingArray.h"
#import "VOPipelineStage.h"

@interface PVSectionedDataSource ()

- (instancetype)initWithSections:(NSArray *)sectionDataSources
               changeDescription:(PVSectionedDataSourceChangeDescription *)changeDescription;
@end

@interface PVSectionedDataSourceChangeDescription ()
- (instancetype)initWithInsertedIndexPaths:(NSArray *)insertedIndexPaths removedIndexPaths:(NSArray *)removedIndexPaths;
@end

@implementation PVSectionedDataSource
{
  @protected
  NSArray *_sectionDataSources;
}

- (instancetype)initWithSections:(NSArray *)sectionDataSources
               changeDescription:(PVSectionedDataSourceChangeDescription *)changeDescription
{
  self = [super init];
  if (self != nil) {
    _sectionDataSources = [[NSArray alloc] initWithArray:sectionDataSources copyItems:YES];
    _changeDescription = changeDescription;
  }
  return self;
}

- (instancetype)initWithSections:(NSArray *)sectionDataSources
{
  return [self initWithSections:sectionDataSources changeDescription:nil];
}

- (instancetype)init
{
  return [self initWithSections:nil changeDescription:nil];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ sections = %@", [super description], _sectionDataSources];
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

- (VOChangeDescribingArray *)objectAtIndexedSubscript:(NSUInteger)index
{
  return _sectionDataSources[index];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
  return self;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
  return [[PVMutableSectionedDataSource alloc] initWithSections:_sectionDataSources changeDescription:nil];
}

@end

@implementation PVMutableSectionedDataSource
{
  NSMutableIndexSet *_changedSections;
}

- (instancetype)initWithSections:(NSArray *)sectionDataSources changeDescription:(PVSectionedDataSourceChangeDescription *)changeDescription
{
  self = [super initWithSections:sectionDataSources changeDescription:changeDescription];
  if (self != nil) {
    _sectionDataSources = [sectionDataSources mutableCopy];
    _changedSections = [[NSMutableIndexSet alloc] init];
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  return [[PVSectionedDataSource alloc] initWithSections:_sectionDataSources
                                       changeDescription:self.changeDescription];
}

- (void)setObject:(VOChangeDescribingArray *)sectionDataSource atIndexedSubscript:(NSUInteger)idx
{
  [_changedSections addIndex:idx];
  [(NSMutableArray *)_sectionDataSources replaceObjectAtIndex:idx withObject:sectionDataSource];
}

- (PVSectionedDataSourceChangeDescription *)changeDescription
{
  NSMutableArray *insertedIndexPaths = [[NSMutableArray alloc] init];
  NSMutableArray *removedIndexPaths = [[NSMutableArray alloc] init];
  
  [_changedSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    VOChangeDescribingArray *section = _sectionDataSources[idx];
    VOArrayChangeDescription *sectionChangeDescription = section.changeDescription;
    [insertedIndexPaths addObjectsFromArray:[sectionChangeDescription.indexesToAddFromUpdatedValues pv_arrayOfIndexPathsFromSection:idx]];
    [removedIndexPaths addObjectsFromArray:[sectionChangeDescription.indexesToRemoveFromOldValues pv_arrayOfIndexPathsFromSection:idx]];
  }];
  return [[PVSectionedDataSourceChangeDescription alloc] initWithInsertedIndexPaths:insertedIndexPaths removedIndexPaths:removedIndexPaths];
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

