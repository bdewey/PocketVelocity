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

- (instancetype)init
{
  [[NSException exceptionWithName:@"Not designated initializer" reason:@"Not designated initializer" userInfo:nil] raise];
  return nil;
}

- (instancetype)initWithTitle:(NSString *)title note:(NSString *)note tags:(NSArray *)tags dateAdded:(NSDate *)dateAdded dateModified:(NSDate *)dateModified
{
  self = [super init];
  if (self != nil) {
    _title = [title copy];
    _note = [note copy];
    _tags = [tags copy];
    _dateAdded = dateAdded;
    _dateModified = dateModified;
  }
  return self;
}

- (NSString *)description
{
  return [_title copy];
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
    PVObjectsAreEqual(_dateModified, otherNote->_dateModified);
}

- (NSUInteger)hash
{
  NSUInteger result = 33 + [_title hash];
  result = result * 33 + [_note hash];
  result = result * 33 + [_tags hash];
  result = result * 33 + [_dateAdded hash];
  result = result * 33 + [_dateModified hash];
  return result;
}

#pragma mark - NSCopying

// These objects are immutable so retain instead of copy.
- (instancetype)copyWithZone:(NSZone *)zone
{
  return self;
}

@end

@implementation PVNoteBuilder

- (instancetype)init
{
  return [super init];
}

- (instancetype)initWithNote:(PVNote *)note
{
  self = [self init];
  if (self != nil) {
    _title = [note.title copy];
    _note = [note.note copy];
    _tags = [note.tags copy];
    _dateAdded = note.dateAdded;
    _dateModified = note.dateModified;
  }
  return self;
}

- (PVNote *)newNote
{
  return [[PVNote alloc] initWithTitle:_title note:_note tags:_tags dateAdded:_dateAdded dateModified:_dateModified];
}

@end
