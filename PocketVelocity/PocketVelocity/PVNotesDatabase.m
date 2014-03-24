//
//  PVNotesDatabase.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVMutableListenableArray.h"
#import "PVNotesDatabase.h"

@interface PVNotesDatabase () <PVListening>

@end

@implementation PVNotesDatabase
{
  PVMutableListenableArray *_notes;
}

- (instancetype)initWithDirectory:(NSURL *)directory
{
  self = [super init];
  if (self != nil) {
    _directory = [directory copy];
  }
  return self;
}

- (PVMutableListenableArray *)notes
{
  if (_notes != nil) {
    return _notes;
  }
  NSError *error;
  NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:_directory
                                                             includingPropertiesForKeys:nil
                                                                                options:0
                                                                                  error:&error];
  
  return nil;
}

#pragma mark - PVListening

- (void)listenableObject:(id)object didChangeWithDescription:(id)changeDescription
{
  
}

@end
