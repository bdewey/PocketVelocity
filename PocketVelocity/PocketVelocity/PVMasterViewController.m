//
//  PVMasterViewController.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/15/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "BDLongestCommonSubsequence.h"
#import "PVDetailViewController.h"
#import "VOMutableChangeDescribingArray.h"
#import "PVMasterViewCellConfiguration.h"
#import "PVMasterViewController.h"
#import "PVNote.h"
#import "PVNotesDatabase.h"
#import "PVSectionedDataSource.h"
#import "PVSectionedDataSourceTransformer.h"

#import "VOArrayChangeDescription.h"
#import "VOArrayMapTransformer.h"
#import "VOAsyncPipelineStage.h"
#import "VOBlockListener.h"
#import "VOBlockTransformer.h"
#import "VOChangeDescribingDictionary.h"
#import "VODictionaryMapTransformer.h"
#import "VODictionaryToValuesTransformer.h"
#import "VOMutableChangeDescribingDictionary.h"
#import "VOTransformingPipelineStage.h"

@interface PVMasterViewController () {
  PVNotesDatabase *_notesDatabase;
  VOTransformingPipelineStage *_cellConfigurationsPipeline;
  VOBlockListener *_cellConfigurationsListener;
  VOBlockListener *_autoSaveListener;
}

@property (nonatomic, readwrite, strong) PVSectionedDataSource *cellConfigurations;
- (void)setCellConfigurations:(PVSectionedDataSource *)cellConfigurations animated:(BOOL)animated;

@end

@implementation PVMasterViewController

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
  [_cellConfigurationsListener invalidate];
  _cellConfigurationsListener = [self _cellConfigurationListenerForSource:_notesDatabase];
  [_autoSaveListener invalidate];
  _autoSaveListener = [_notesDatabase autoSaveListener];
  [_notesDatabase startPipeline];
}

- (VOBlockListener *)_cellConfigurationListenerForSource:(id<VOPipelineSource>)source
{
  __weak PVMasterViewController *weakSelf = self;
  return [[[[[[VOAsyncPipelineStage alloc] initWithSource:source queueName:@"com.brians-brain.pocket-velocity.master-list"] pipelineStageWithDictionaryToValuesWithComparator:^NSComparisonResult(PVNote *obj1, PVNote *obj2) {
    return [obj1.title compare:obj2.title];
  }] pipelineWithArrayMappingBlock:^PVMasterViewCellConfiguration *(PVNote *value) {
    return [[PVMasterViewCellConfiguration alloc] initWithNote:value];
  }] pipelineTransformingToSectionedDataSource] mainQueueBlock:^(PVSectionedDataSource *value) {
    [weakSelf setCellConfigurations:value animated:YES];
  }];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
  [_notesDatabase updateNotesWithBlock:^VOChangeDescribingDictionary *(VOChangeDescribingDictionary *currentNotes) {
    NSString *noteTitle = [NSString stringWithFormat:@"Note %lu", (unsigned long)currentNotes.count + 1];
    NSDate *now = [NSDate date];
    PVNote *note = [[PVNote alloc] initWithTitle:noteTitle note:@"Note body" tags:@[@"tag1", @"tag2"] dateAdded:now dateModified:now dirty:YES];
    VOMutableChangeDescribingDictionary *mutableNotes = [currentNotes mutableCopy];
    mutableNotes[noteTitle] = note;
    return [mutableNotes copy];
  }];
}

#pragma mark - PVListening

- (void)setCellConfigurations:(PVSectionedDataSource *)cellConfigurations animated:(BOOL)animated
{
  if (_cellConfigurations == cellConfigurations) {
    return;
  }
  _cellConfigurations = cellConfigurations;
  PVSectionedDataSourceChangeDescription *changeDescription = _cellConfigurations.changeDescription;
  if (animated && changeDescription) {
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:changeDescription.removedIndexPaths
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView insertRowsAtIndexPaths:changeDescription.insertedIndexPaths
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
  } else {
    [self.tableView reloadData];
  }
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
  PVMasterViewCellConfiguration *configuration = [_cellConfigurations objectAtIndexPath:indexPath];
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [_notesDatabase removeNoteWithTitle:configuration.noteIdentifier];
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
    PVMasterViewCellConfiguration *configuration = [_cellConfigurations objectAtIndexPath:indexPath];
    self.detailViewController.detailItem = configuration.noteIdentifier;
    self.detailViewController.notesDatabase = _notesDatabase;
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    PVDetailViewController *detailViewController = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    PVMasterViewCellConfiguration *configuration = [_cellConfigurations objectAtIndexPath:indexPath];
    [detailViewController setDetailItem:configuration.noteIdentifier];
    detailViewController.notesDatabase = _notesDatabase;
  }
}

@end
