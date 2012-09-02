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
#import "DirectDownloadDelegate.h"

@implementation NSURLConnection (DirectDownload)

+ (BOOL) downloadAtURL:(NSURL *)url searching:(NSString*)batchNumber viewingOn:(id)viewDelegate {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    DirectDownloadDelegate *delegate = [[[DirectDownloadDelegate alloc] initWithNeedle:batchNumber andViewDelegate:viewDelegate] autorelease];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
    [request release];

    while ([delegate isDone] == NO) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }

    if ([delegate isFound] != YES) {
        [viewDelegate appendStatus:@"This batch number is not found."];
        NSLog(@"This batch number is not found.");
    }

    NSLog(@"PDF is processed");
    [connection release];

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
    NSString* lastUpdateDate = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"Last update at: %@", lastUpdateDate);
    [viewDelegate setCompleteDate:lastUpdateDate];
    [dateFormatter release];

    NSError *error = [delegate error];
    if (error != nil) {
        NSLog(@"Download error: %@", error);
        return NO;
    }

    return YES;
}

@end
