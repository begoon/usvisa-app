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

#import "DirectDownloadViewDelegate.h"

@interface DirectDownloadDelegate : NSObject {
    NSError *error;
    BOOL done;
    BOOL found;
    NSMutableData *receivedData;
    float expectedBytes, receivedBytes;
    id<DirectDownloadViewDelegate> viewDelegate;
    NSString* needle;
}

- (id) initWithNeedle:(NSString*)aNeedle andViewDelegate:(id<DirectDownloadViewDelegate>)aViewDelegate;

@property (atomic, readonly, getter=isDone) BOOL done;
@property (atomic, readonly, getter=isFound) BOOL found;
@property (atomic, readonly) NSError *error;

@end
