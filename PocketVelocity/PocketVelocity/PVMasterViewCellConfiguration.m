//
//  PVMasterViewCellConfiguration.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/17/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVMasterViewCellConfiguration.h"
#import "PVNote.h"
#import "PVUtilities.h"

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
  }
  return self;
}

- (void)configureCell:(UITableViewCell *)cell
{
  cell.textLabel.text = _titleText;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ title = %@", [super description], _titleText];
}

- (BOOL)isEqual:(id)object
{
  return [object isKindOfClass:[self class]] &&
    PVStringsAreEqual(_titleText, ((PVMasterViewCellConfiguration *)object)->_titleText);
}

- (NSUInteger)hash
{
  return [_titleText hash];
}

@end
