//
//  PVAnnouncing.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/15/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PVAnnouncing <NSObject>

- (void)addListener:(id)listener;
- (void)removeListener:(id)listener;

@end
