//
//  PVDetailViewController.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/15/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVDetailViewController.h"
#import "PVNote.h"
#import "PVNotesDatabase.h"
#import "PVUtilities.h"
#import "VOAsyncPipelineStage.h"
#import "VOArrayFilterer.h"
#import "VOBlockListener.h"
#import "VOBlockTransformer.h"
#import "VODictionaryFilterer.h"
#import "VODictionaryToValuesTransformer.h"
#import "VOPipelineStage.h"
#import "VOMutableChangeDescribingArray.h"
#import "VOTransformingPipelineStage.h"
#import "VOValueTransforming.h"

@interface PVDetailViewController () <UITextViewDelegate>
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@property (strong, nonatomic) PVNote *currentNote;
- (void)configureView;
@end

@implementation PVDetailViewController
{
  VOBlockListener *_currentNoteListener;
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(NSString *)newDetailItem
{
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
    [self _configureCurrentNotePipeline];
  }
  
  if (self.masterPopoverController != nil) {
    [self.masterPopoverController dismissPopoverAnimated:YES];
  }
}

- (void)setNotesDatabase:(PVNotesDatabase *)notesDatabase
{
  if (_notesDatabase != notesDatabase) {
    _notesDatabase = notesDatabase;
    [self _configureCurrentNotePipeline];
  }
}

- (void)setCurrentNote:(PVNote *)currentNote
{
  if (!PVObjectsAreEqual(_currentNote, currentNote)) {
    _currentNote = currentNote;
    [self configureView];
  }
}

- (void)_configureCurrentNotePipeline
{
  VOPipelineStage *pipeline = [[self class] _pipelineForFilteringWithTitle:_detailItem fromSource:_notesDatabase];
  [_currentNoteListener invalidate];
  __weak PVDetailViewController *weakSelf = self;
  _currentNoteListener = [[VOBlockListener alloc] initWithSource:pipeline block:^(VOChangeDescribingArray *value) {
    PVDetailViewController *strongSelf = weakSelf;
    if (value.count > 0) {
      strongSelf.currentNote = value[0];
    }
  }];
  [pipeline startPipeline];
}

- (void)configureView
{
  if (_currentNote) {
    self.title = _currentNote.title;
    self.noteTextView.text = _currentNote.note;
  }
}

+ (VOPipelineStage *)_pipelineForFilteringWithTitle:(NSString *)title fromSource:(id<VOPipelineSource>)source
{
  return [[[[VOAsyncPipelineStage alloc] initWithSource:source queueName:@"com.brians-brain.pocket-velocity.detail-view"] pipelineByFilteringDictionaryWithBlock:^BOOL(NSString *noteTitle, PVNote *note) {
    if ([title isEqualToString:noteTitle]) {
      return YES;
    }
    return NO;
  }] pipelineStageWithDictionaryToValuesWithComparator:^NSComparisonResult(PVNote *obj1, PVNote *obj2) {
    return [obj1.title compare:obj2.title];
  }];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.noteTextView.delegate = self;
  [self configureView];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
  barButtonItem.title = NSLocalizedString(@"Master", @"Master");
  [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
  self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
  // Called when the view is shown again in the split view, invalidating the button and popover controller.
  [self.navigationItem setLeftBarButtonItem:nil animated:YES];
  self.masterPopoverController = nil;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
  PVMutableNote *updatedNote = [_currentNote mutableCopy];
  updatedNote.note = textView.text;
  updatedNote.dirty = YES;
  PVNote *immutableCopy = [updatedNote copy];
  _currentNote = immutableCopy;
  [_notesDatabase updateNote:immutableCopy];
}

@end
