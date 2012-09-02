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

@interface ViewController : NSObject <DirectDownloadViewDelegate>
- (bool) updateBatchStatus:(NSString*)batchNumber;
@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        ViewController* viewController = [ViewController alloc];
        [viewController updateBatchStatus:[NSString stringWithCString:argv[1] encoding:NSASCIIStringEncoding]];
        [viewController release];
    }
    return 0;
}
