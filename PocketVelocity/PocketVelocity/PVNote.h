//
//  PVNote.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/15/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVNote : NSObject <NSCopying>

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *note;
@property (nonatomic, readonly, copy) NSArray *tags;
@property (nonatomic, readonly, strong) NSDate *dateAdded;
@property (nonatomic, readonly, strong) NSDate *dateModified;

- (instancetype)initWithTitle:(NSString *)title note:(NSString *)note tags:(NSArray *)tags dateAdded:(NSDate *)dateAdded dateModified:(NSDate *)dateModified;

@end

@interface PVNoteBuilder : NSObject

@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) NSString *note;
@property (nonatomic, readwrite, copy) NSArray *tags;
@property (nonatomic, readwrite, strong) NSDate *dateAdded;
@property (nonatomic, readwrite, strong) NSDate *dateModified;

- (instancetype)init;
- (instancetype)initWithNote:(PVNote *)note;

- (PVNote *)newNote;

@end
