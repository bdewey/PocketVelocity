//
//  PVSectionedDataSource.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PVListenable.h"
#import "VOChangeDescribingArray.h"

/**
 When you listen for changes to this data source, the change description is class `PVSectionedDataSourceChangeDescription`
 */
@interface PVSectionedDataSource : NSObject <PVListenable>

/**
 @param sectionDataSources An array of PVListenableArrayDataSource objects.
 */
- (instancetype)initWithSections:(NSArray *)sectionDataSources;

- (NSUInteger)countOfSections;
- (NSUInteger)countOfItemsInSection:(NSUInteger)section;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)objectsAtIndexPaths:(NSArray *)indexPaths;

@end

@interface PVSectionedDataSourceChangeDescription : NSObject

@property (nonatomic, readonly, copy) NSArray *insertedIndexPaths;
@property (nonatomic, readonly, copy) NSArray *removedIndexPaths;

@end

@interface VOChangeDescribingArray (PVSectionedDataSource)

- (PVSectionedDataSource *)sectionedDataSource;

@end