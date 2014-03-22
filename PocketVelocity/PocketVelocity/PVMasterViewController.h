//
//  PVMasterViewController.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/15/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PVDetailViewController;

@interface PVMasterViewController : UITableViewController

@property (strong, nonatomic) PVDetailViewController *detailViewController;

@end
