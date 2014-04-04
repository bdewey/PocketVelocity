//
//  PVMasterViewCellConfiguration.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/17/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVMasterViewCellConfiguration.h"
#import "PVNote.h"
#import "VOUtilities.h"

@implementation PVMasterViewCellConfiguration
{
  NSString *_titleText;
}

- (instancetype)initWithNote:(PVNote *)note
{
  self = [super init];
  if (self != nil) {
    _titleText = [note.title copy];
    _reuseIdentifier = NSStringFromClass([self class]);
    _noteIdentifier = [note.title copy];
    _dirty = note.dirty;
  }
  return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
  return self;
}

- (void)configureCell:(UITableViewCell *)cell
{
  cell.textLabel.text = [NSString stringWithFormat:@"%@%@", _dirty?@"* ":@"", _titleText];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ title = %@", [super description], _titleText];
}

- (BOOL)isEqual:(id)object
{
  PVMasterViewCellConfiguration *objectAsConfiguration = (PVMasterViewCellConfiguration *)object;
  return [object isKindOfClass:[self class]] &&
    VOStringsAreEqual(_titleText, objectAsConfiguration->_titleText) &&
    _dirty == objectAsConfiguration->_dirty;
}

- (NSUInteger)hash
{
  return [_titleText hash] * 31 + [@(_dirty) hash];
}

@end
