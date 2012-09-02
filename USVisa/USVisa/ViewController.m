/*
 * Copyright (C) 2012 Alexander Demin, <alexander@demin.ws>
 *
 * This file is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.
 *
 * You can redistribute this file and/or modify it under the terms of the GNU
 * General Public License (GPL) as published by the Free Software Foundation;
 * either version 2 of the License, or (at your discretion) any later version.
 * See the accompanying file "COPYING" for more details.
 */

#import <Foundation/Foundation.h>

#import "DirectDownloadViewDelegate.h"

#ifdef TESTING
#define IBAction void
@interface ViewController : NSObject <DirectDownloadViewDelegate>
@end
#else
#import "ViewController.h"
#endif

#import "NSURLConnectionDirectDownload.h"

static char const* const pdf = "http://photos.state.gov/libraries/unitedkingdom/164203/cons-visa/admin_processing_dates.pdf";

@implementation ViewController

#ifndef TESTING
@synthesize updateProgressView, batchNumberTextField, statusTextView, lastUpdatedLabel, updateButton;
#endif

NSString* const PropertiesFilename = @"Properties";

NSString *pathInDocumentDirectory(NSString *fileName) {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

- (void) dealloc {
    [super dealloc];
}

- (void) appendStatus:(NSString*)status {
    NSLog(@"appendStatus(): '%@'", [status stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"]);
#ifndef TESTING
    if ([[statusTextView text] length] == 0)
        [statusTextView setText:@"Status:\n"];
    [statusTextView setText:[[statusTextView text] stringByAppendingString:status]];
    [statusTextView setText:[[statusTextView text] stringByAppendingString:@"\n"]];
#endif
}

- (void) setProgress:(float)progress {
#ifndef TESTING
    updateProgressView.progress = progress;
#endif
}

- (void) setCompleteDate:(NSString*)date {
    NSLog(@"setCompleteDate(): '%@'", date);
#ifndef TESTING
    [lastUpdatedLabel setText:date];
#endif
}

- (bool) updateBatchStatus:(NSString*)batchNumber {
    NSURL *url = [[[NSURL alloc] initWithString:[NSString stringWithCString:pdf encoding:NSASCIIStringEncoding]] autorelease];
    return [NSURLConnection downloadAtURL:url searching:batchNumber viewingOn:self];
}

#ifndef TESTING
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    spinnerActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinnerActivityIndicatorView setColor:[UIColor blueColor]];
    CGSize size = [[self view] frame].size;
    [spinnerActivityIndicatorView setCenter:CGPointMake(size.width / 2, size.height / 2 + 60)];
    [self.view addSubview:spinnerActivityIndicatorView];

    CGRect rect = [self.updateButton bounds];
    rect.size.height += 10;
    [self.updateButton setBounds:rect];

    rect = [self.batchNumberTextField bounds];
    rect.size.height += 20;
    [self.batchNumberTextField setBounds:rect];

#ifdef DEBUG
    NSLog(@"DEBUG mode");
#endif
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#endif

- (IBAction)launchUpdate:(id)sender {
    [self setProgress:0.0];
#ifndef TESTING
    [updateButton setEnabled: NO];
    [updateProgressView setHidden:NO];

    NSString* previousStatus = [statusTextView text];
    [statusTextView setText:@""];

    NSString* batchNumber = [batchNumberTextField text];

    [spinnerActivityIndicatorView startAnimating];
    BOOL const ok = [self updateBatchStatus:batchNumber];
    [spinnerActivityIndicatorView stopAnimating];

    if (!ok) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Internet connectivity problem"
                                                       delegate:self cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
        [statusTextView setText:previousStatus];
    }

    [updateProgressView setHidden:YES];
    [updateButton setEnabled: YES];
#endif
}

- (void) saveProperties {
    NSDictionary *props = [[NSDictionary alloc] initWithObjectsAndKeys:
#ifndef TESTING
                          batchNumberTextField.text, @"batchNumberTextField",
                          statusTextView.text, @"statusTextView",
                          lastUpdatedLabel.text, @"lastUpdatedLabel",
#endif
                           nil];
    for (NSString* key in props) {
        NSLog(@"%@ - %@", key, [props objectForKey:key]);
    }

    NSString* filename = pathInDocumentDirectory(PropertiesFilename);
    if ([props writeToFile:filename atomically:YES] == NO)
        NSLog(@"Unable to save properties into file [%@]", filename);

    [props release];
}

- (void) loadProperties {
    NSDictionary *props = [[NSDictionary alloc] initWithContentsOfFile:pathInDocumentDirectory(PropertiesFilename)];
    for (NSString* key in props) {
        NSLog(@"%@ - %@", key, [props objectForKey:key]);
    }

#ifndef TESTING
    [batchNumberTextField setText:[props objectForKey:@"batchNumberTextField"]];
    [statusTextView setText:[props objectForKey:@"statusTextView"]];
    [lastUpdatedLabel setText:[props objectForKey:@"lastUpdatedLabel"]];
#endif
    [props release];
}

- (IBAction)textFieldReturn:(id)sender {
#ifndef TESTING
    [sender resignFirstResponder];
#endif
}

-(IBAction)backgroundTouched:(id)sender {
#ifndef TESTING
    [batchNumberTextField resignFirstResponder];
#endif
}

@end
