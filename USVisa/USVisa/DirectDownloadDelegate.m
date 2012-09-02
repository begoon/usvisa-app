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
#import "BatchPDFParser.h"

@implementation DirectDownloadDelegate
@synthesize error, done, found;

- (id) initWithNeedle:(NSString*)aNeedle andViewDelegate:(id<DirectDownloadViewDelegate>)aViewDelegate {
    viewDelegate = aViewDelegate;
    [viewDelegate retain];

    needle = [[NSString alloc] initWithString:aNeedle];
    receivedData = [[NSMutableData alloc] init];
    expectedBytes = receivedBytes = 0.0;
    found = NO;

    return self;
}

- (void) dealloc {
    [error release];
    [receivedData release];
    [needle release];
    [viewDelegate release];
    [super dealloc];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    done = YES;
    NSLog(@"Connection finished");
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)anError {
    error = [anError retain];
    [self connectionDidFinishLoading:connection];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)someData {
    receivedBytes += [someData length];
    [viewDelegate setProgress:(receivedBytes / expectedBytes)];
    [receivedData appendData:someData];

    NSMutableArray* list = [[NSMutableArray alloc] init];
    bool foundInCurrentPortion = [BatchPDFParser findInPortion:receivedData needle:needle andAddTo:list];
    for (id batch in list) {
      NSLog(@"[%@]", [batch stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"]);
      [viewDelegate appendStatus:batch];
    }
    [list release];
    found = found || foundInCurrentPortion;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)someResponse {
    NSDictionary *headers = [someResponse allHeaderFields];
    NSLog(@"[didReceiveResponse] response headers: %@", headers);
    if (headers) {
        if ([headers objectForKey: @"Content-Length"]) {
            NSLog(@"Content-Length: %@", [headers objectForKey: @"Content-Length"]);
            expectedBytes = [[headers objectForKey: @"Content-Length"] floatValue];
        } else {
            NSLog(@"No Content-Length header found");
        }
    }
}

@end
