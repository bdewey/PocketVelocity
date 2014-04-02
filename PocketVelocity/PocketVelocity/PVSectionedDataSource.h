//
//  PVSectionedDataSource.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VOPipelining.h"
#import "VOChangeDescribing.h"
#import "VOChangeDescribingArray.h"

@class PVSectionedDataSourceChangeDescription;

@interface PVSectionedDataSource : NSObject <NSCopying, NSMutableCopying, VOChangeDescribing>

@property (nonatomic, readonly, strong) PVSectionedDataSourceChangeDescription *changeDescription;

/**
 @param sectionDataSources An array of VOChangeDescribingArray objects.
 */
- (instancetype)initWithSections:(NSArray *)sectionDataSources;

- (NSUInteger)countOfSections;
- (NSUInteger)countOfItemsInSection:(NSUInteger)section;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)objectsAtIndexPaths:(NSArray *)indexPaths;
- (VOChangeDescribingArray *)objectAtIndexedSubscript:(NSUInteger)index;

@end

@interface PVMutableSectionedDataSource : PVSectionedDataSource

- (void)setObject:(VOChangeDescribingArray *)sectionDataSource atIndexedSubscript:(NSUInteger)idx;

@end

@interface PVSectionedDataSourceChangeDescription : NSObject

@property (nonatomic, readonly, copy) NSArray *insertedIndexPaths;
@property (nonatomic, readonly, copy) NSArray *removedIndexPaths;

@end

