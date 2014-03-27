//
//  PVDetailViewController.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/15/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVDetailViewController.h"
#import "PVListenersCollection.h"
#import "PVMutableListenableArray.h"
#import "PVNote.h"
#import "PVUtilities.h"

@interface PVDetailViewController () <UITextViewDelegate>
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
- (void)configureView;
@end

@implementation PVDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(PVNote *)newDetailItem
{
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
    
    // Update the view.
    [self configureView];
  }
  
  if (self.masterPopoverController != nil) {
    [self.masterPopoverController dismissPopoverAnimated:YES];
  }
}

- (void)configureView
{
  // Update the user interface for the detail item.
  
  if (self.detailItem) {
    self.title = _detailItem.title;
    self.noteTextView.text = _detailItem.note;
  }
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
  PVMutableNote *updatedNote = [_detailItem mutableCopy];
  updatedNote.note = textView.text;
  updatedNote.dirty = YES;
  for (int i = 0; i < _notesDatabase.count; i++) {
    PVNote *oldNote = _notesDatabase[i];
    if (PVStringsAreEqual(_detailItem.title, oldNote.title)) {
      _notesDatabase[i] = updatedNote;
      break;
    }
  }
  _detailItem = [updatedNote copy];
}

@end
