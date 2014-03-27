//
//  PVMasterViewController.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/15/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "BDLongestCommonSubsequence.h"
#import "VOArrayChangeDescription.h"
#import "PVAsyncListening.h"
#import "PVDetailViewController.h"
#import "VOMutableChangeDescribingArray.h"
#import "VOArrayMapTransformer.h"
#import "PVMasterViewCellConfiguration.h"
#import "PVMasterViewController.h"
#import "PVNote.h"
#import "PVNotesDatabase.h"
#import "PVSectionedDataSource.h"

@interface PVMasterViewController () <PVListening> {
  PVNotesDatabase *_notesDatabase;
  VOMutableChangeDescribingArray *_notes;
  PVSectionedDataSource *_cellConfigurations;
}
@end

@implementation PVMasterViewController

- (void)dealloc
{
  [_cellConfigurations removeListener:self];
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
  
  NSError *error;
  NSURL *documents = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
  if (!documents) {
    @throw [NSException exceptionWithName:NSDestinationInvalidException reason:@"Unable to open documents directory" userInfo:@{@"error": error}];
  }
  _notesDatabase = [[PVNotesDatabase alloc] initWithDirectory:documents];
  // FIXME: Fix this shit
//  _notes = [_notesDatabase notes];
//  _cellConfigurations = [[[[_notes defaultQueueArray] mappedArrayWithMappingBlock:^PVMasterViewCellConfiguration *(PVNote *note) {
//    return [[PVMasterViewCellConfiguration alloc] initWithNote:note];
//  }] mainQueueArray] sectionedDataSource];
  [_cellConfigurations addListener:self];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
  NSString *noteTitle = [NSString stringWithFormat:@"Note %u", _notes.count + 1];
  NSDate *now = [NSDate date];
  PVNote *note = [[PVNote alloc] initWithTitle:noteTitle note:@"Note body" tags:@[@"tag1", @"tag2"] dateAdded:now dateModified:now dirty:YES];
  [_notes addObject:note];
}

#pragma mark - PVListening

- (void)listenableObject:(id)object didChangeWithDescription:(PVSectionedDataSourceChangeDescription *)changeDescription
{
  [self.tableView beginUpdates];
  [self.tableView deleteRowsAtIndexPaths:changeDescription.removedIndexPaths
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView insertRowsAtIndexPaths:changeDescription.insertedIndexPaths
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [_cellConfigurations countOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_cellConfigurations countOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  PVMasterViewCellConfiguration *configuration = [_cellConfigurations objectAtIndexPath:indexPath];
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:configuration.reuseIdentifier
                                                          forIndexPath:indexPath];

  [configuration configureCell:cell];
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
