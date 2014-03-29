//
//  PVListenable.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VOListening;

@protocol VOListenable <NSObject>

- (id)addListener:(id<VOListening>)listener;
- (void)removeListener:(id<VOListening>)listener;

@end

@protocol VOListening <NSObject>

- (void)listenableObject:(id<VOListenable>)listenableObject didUpdateToValue:(id)value;

@end