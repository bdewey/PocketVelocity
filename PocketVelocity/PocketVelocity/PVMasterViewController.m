//
//  PVMasterViewController.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/15/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "BDLongestCommonSubsequence.h"
#import "NSIndexSet+PVUtilities.h"
#import "PVArrayChangeDescription.h"
#import "PVDetailViewController.h"
#import "PVMutableListenableArray.h"
#import "PVMasterViewCellConfiguration.h"
#import "PVMasterViewController.h"
#import "PVNote.h"

@interface PVMasterViewController () <PVListening> {
  PVMutableListenableArray *_notes;
}
@end

@implementation PVMasterViewController

- (void)dealloc
{
  [_notes removeListener:self];
}

- (void)awakeFromNib
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
  }
  [super awakeFromNib];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.navigationItem.leftBarButtonItem = self.editButtonItem;
  
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
  self.navigationItem.rightBarButtonItem = addButton;
  self.detailViewController = (PVDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
  
  _notes = [[PVMutableListenableArray alloc] init];
  [_notes addListener:self];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
  static NSUInteger noteCounter = 0;
  NSString *noteTitle = [NSString stringWithFormat:@"Note %u", noteCounter++];
  NSDate *now = [NSDate date];
  PVNote *note = [[PVNote alloc] initWithTitle:noteTitle note:@"Note body" tags:@[@"tag1", @"tag2"] dateAdded:now dateModified:now];
  [_notes addObject:note];
}

#pragma mark - PVListening

- (void)listenableObject:(id)object didChangeWithDescription:(PVArrayChangeDescription *)changeDescription
{
  [self.tableView beginUpdates];
  [self.tableView deleteRowsAtIndexPaths:[changeDescription.indexesToRemoveFromOldValues pv_indexPathsForSection:0]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView insertRowsAtIndexPaths:[changeDescription.indexesToAddFromUpdatedValues pv_indexPathsForSection:0]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  
  PVNote *note = _notes[indexPath.row];
  cell.textLabel.text = [note description];
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Return NO if you do not want the specified item to be editable.
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [_notes removeObjectAtIndex:indexPath.row];
  } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
  }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    self.detailViewController.detailItem = _notes[indexPath.row];
    self.detailViewController.notesDatabase = _notes;
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    PVDetailViewController *detailViewController = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [detailViewController setDetailItem:_notes[indexPath.row]];
    detailViewController.notesDatabase = _notes;
  }
}

@end
