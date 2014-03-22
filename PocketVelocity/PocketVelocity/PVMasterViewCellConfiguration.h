//
//  PVMasterViewCellConfiguration.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/17/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PVNote;

@interface PVMasterViewCellConfiguration : NSObject

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;

- (instancetype)initWithNote:(PVNote *)note;
- (void)configureCell:(UITableViewCell *)cell;

@end
