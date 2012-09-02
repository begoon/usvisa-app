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

@interface Batch: NSObject {
  NSString *batchNumber, *status, *date;
}

@property (atomic, copy) NSString* batchNumber, *status, *date;
@end

@interface BatchPDFParser: NSObject

+ (bool)findInPortion:(NSMutableData *)data needle:(NSString* const)needle andAddTo:(NSMutableArray*)list;

@end
