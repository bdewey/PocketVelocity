//
//  PVNote.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/15/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVNote.h"
#import "PVUtilities.h"

@implementation PVNote
{
  @protected
  NSString *_title;
  NSString *_note;
  NSArray *_tags;
  NSDate *_dateAdded;
  NSDate *_dateModified;
  BOOL _dirty;
}

- (instancetype)init
{
  [[NSException exceptionWithName:@"Not designated initializer" reason:@"Not designated initializer" userInfo:nil] raise];
  return nil;
}

- (instancetype)initWithTitle:(NSString *)title note:(NSString *)note tags:(NSArray *)tags dateAdded:(NSDate *)dateAdded dateModified:(NSDate *)dateModified dirty:(BOOL)dirty
{
  self = [super init];
  if (self != nil) {
    _title = [title copy];
    _note = [note copy];
    _tags = [tags copy];
    _dateAdded = dateAdded;
    _dateModified = dateModified;
    _dirty = dirty;
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@%@", _title, _dirty?@" (dirty)":@""];
}

- (BOOL)isEqual:(id)object
{
  if (object == self) {
    return YES;
  }
  if (![object isKindOfClass:[self class]]) {
    return NO;
  }
  PVNote *otherNote = (PVNote *)object;
  return PVStringsAreEqual(_title, otherNote->_title) &&
    PVStringsAreEqual(_note, otherNote->_note) &&
    PVObjectsAreEqual(_tags, otherNote->_tags) &&
    PVObjectsAreEqual(_dateAdded, otherNote->_dateAdded) &&
    PVObjectsAreEqual(_dateModified, otherNote->_dateModified) &&
    _dirty == otherNote->_dirty;
}

- (NSUInteger)hash
{
  NSUInteger result = 33 + [_title hash];
  result = result * 33 + [_note hash];
  result = result * 33 + [_tags hash];
  result = result * 33 + [_dateAdded hash];
  result = result * 33 + [_dateModified hash];
  result = result * 33 + [@(_dirty) hash];
  return result;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
  return [[PVMutableNote alloc] initWithTitle:_title
                                         note:_note
                                         tags:_tags
                                    dateAdded:_dateAdded
                                 dateModified:_dateModified
                                        dirty:_dirty];
}

@end

@implementation PVMutableNote

- (void)setTitle:(NSString *)title
{
  _title = [title copy];
}

- (void)setNote:(NSString *)note
{
  _note = [note copy];
}

- (void)setTags:(NSArray *)tags
{
  _tags = [tags copy];
}

- (void)setDateAdded:(NSDate *)dateAdded
{
  _dateAdded = dateAdded;
}

- (void)setDateModified:(NSDate *)dateModified
{
  _dateModified = dateModified;
}

- (void)setDirty:(BOOL)dirty
{
  _dirty = dirty;
}

- (id)copyWithZone:(NSZone *)zone
{
  return [[PVNote alloc] initWithTitle:self.title
                                  note:self.note
                                  tags:self.tags
                             dateAdded:self.dateAdded
                          dateModified:self.dateModified
                                 dirty:self.dirty];
}

@end