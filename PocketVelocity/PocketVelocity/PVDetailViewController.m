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
#import "VOArrayFilterer.h"
#import "VOBlockListener.h"
#import "VOBlockTransformer.h"
#import "VOListenersCollection.h"
#import "VOMutableChangeDescribingArray.h"
#import "VOPipeline.h"
#import "VOValueTransforming.h"

@interface PVDetailViewController () <UITextViewDelegate>
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
- (void)configureView;
@end

@implementation PVDetailViewController
{
  PVNote *_currentNote;
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

- (void)_configureCurrentNotePipeline
{
  VOPipeline *pipeline = [[self class] _pipelineForFilteringWithTitle:_detailItem fromSource:_notesDatabase];
  [_currentNoteListener invalidate];
  __weak PVDetailViewController *weakSelf = self;
  _currentNoteListener = [[VOBlockListener alloc] initWithSource:pipeline block:^(VOChangeDescribingArray *value) {
    PVDetailViewController *strongSelf = weakSelf;
    if (value.count > 0) {
      strongSelf->_currentNote = value[0];
      [strongSelf configureView];
    }
  }];
}

- (void)configureView
{
  if (_currentNote) {
    self.title = _currentNote.title;
    self.noteTextView.text = _currentNote.note;
  }
}

+ (VOPipeline *)_pipelineForFilteringWithTitle:(NSString *)title fromSource:(id<VOListenable>)source
{
  VOBlockTransformer *filterItem = [[VOBlockTransformer alloc] initWithBlock:^id(PVNote *value) {
    if ([title isEqualToString:value.title]) {
      return value;
    }
    return nil;
  }];
  VOArrayFilterer *filterArray = [[VOArrayFilterer alloc] initWithTransformer:filterItem
                                                     expectsPipelineSemantics:YES
                                  validationBlock:^BOOL(VOChangeDescribingArray *currentValue) {
                                    return currentValue.count < 2;
                                  }];
  VOPipeline *pipeline = [[VOPipeline alloc] initWithName:@"com.brians-brian.pocket-velocity.detail-view" source:source stages:@[filterArray]];
  return pipeline;
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
  [_notesDatabase updateNotesWithBlock:^VOChangeDescribingArray *(VOChangeDescribingArray *currentNotes) {
    VOMutableChangeDescribingArray *mutableCopy = [currentNotes mutableCopy];
    NSUInteger idx;
    for (idx = 0; idx < mutableCopy.count; idx++) {
      PVNote *note = mutableCopy[idx];
      if ([note.title isEqualToString:immutableCopy.title]) {
        mutableCopy[idx] = immutableCopy;
        break;
      }
    }
    if (idx == mutableCopy.count) {
      [mutableCopy addObject:immutableCopy];
    }
    return mutableCopy;
  }];
}

@end
