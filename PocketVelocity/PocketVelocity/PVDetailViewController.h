//
//  PVDetailViewController.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/15/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PVAnnouncing.h"

@class PVNote;
@class VOMutableChangeDescribingArray;

@interface PVDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) PVNote *detailItem;
@property (strong, nonatomic) VOMutableChangeDescribingArray *notesDatabase;

@end

