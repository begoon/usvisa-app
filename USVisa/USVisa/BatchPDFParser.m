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
#import "BatchPDFParser.h"
#import "zlib.h"

@implementation Batch

@synthesize batchNumber, status, date;

- (void) dealloc {
    [batchNumber release];
    [status release];
    [date release];
    [super dealloc];
}
@end

@implementation BatchPDFParser

+ (int) findInData:(NSMutableData *)data fromOffset:(size_t)offset needle:(char const * const)needle {
    int const needleSize = strlen(needle);
    char const* const bytes = [data mutableBytes];
    int const bytesLength = [data length] - needleSize;
    for (int i = 0; i < bytesLength;) {
        char const* const current = memchr(bytes + i, needle[0], bytesLength - i);
        if (current == NULL) return -1;
        if (memcmp(current, needle, needleSize) == 0) return current - bytes;
        i = current - bytes + 1;
    }
    return -1;
}

+ (bool) isBatchNumber:(NSString*)number {
    long long const value = [number longLongValue];
    return value >= 20000000000L && value < 29000000000L;
}

+ (bool) findBatchNumberInChunk:(char const*)chunk needle:(NSString*)needle andAddTo:(NSMutableArray*)list {
    enum {
        waitBT, waitText, insideText
    } state = waitBT;
    enum {
        waitBatchNumber, waitStatus, waitDate
    } batchParserState = waitBatchNumber;
    NSMutableString* line = [[NSMutableString alloc] init];
    Batch* batch = nil;
    bool found = NO;
    while (*chunk) {
        if (state == waitBT) {
            if (chunk[0] == 'B' && chunk[1] == 'T') {
                state = waitText;
                [line deleteCharactersInRange:NSMakeRange(0, [line length])];
            }
        } else if (state == waitText) {
            if (chunk[0] == '(') {
                state = insideText;
            } else if (chunk[0] == 'E' && chunk[1] == 'T') {
                if (batchParserState == waitBatchNumber) {
                    if ([self isBatchNumber:line]) {
                        [batch autorelease];
                        batch = [[Batch alloc] init];
                        batch.batchNumber = line;
                        batchParserState = waitStatus;
                    }
                } else if (batchParserState == waitStatus) {
                    batch.status = line;
                    batchParserState = waitDate;
                } else if (batchParserState == waitDate) {
                    batch.date = line;
                    batchParserState = waitBatchNumber;
                    if ([batch.batchNumber isEqualToString:needle]) {
                        NSString* pair = [NSString stringWithFormat:@"%@\n%@", batch.status, batch.date];
                        [list addObject:pair];
                        NSLog(@"Found match: '%@' '%@' '%@'", batch.batchNumber, batch.status, batch.date);
                        found = YES;
                    }
                }
                [line autorelease];
                line = [[NSMutableString alloc] init];
                state = waitBT;
            }
        } else if (state == insideText) {
            if (chunk[0] == ')') {
                state = waitText;
            } else {
                char const c[2] = { chunk[0], 0 };
                [line appendString:[NSString stringWithUTF8String:&c[0]]];
            }
        }
        chunk += 1;
    }
    [line release];
    [batch release];
    return found;
}

+ (bool)findInPortion:(NSMutableData *)portion needle:(NSString*)needle andAddTo:(NSMutableArray*)list {
    static char const* const streamStartMarker = "stream\x0d\x0a";
    static char const* const streamStopMarker = "endstream\x0d\x0a";
    bool found = false;
    while (true) {
        int const beginPosition = [self findInData:portion fromOffset:0 needle:streamStartMarker];
        if (beginPosition == -1) break;
        int const endPosition = [self findInData:portion fromOffset:beginPosition needle:streamStopMarker];
        if (endPosition == -1) break;
        int const blockLength = endPosition + strlen(streamStopMarker) - beginPosition;

        char const* const zipped = [portion mutableBytes] + beginPosition + strlen(streamStartMarker);
        z_stream zstream;
        memset(&zstream, 0, sizeof(zstream));
        int const zippedLength = blockLength - strlen(streamStartMarker) - strlen(streamStopMarker);

        zstream.avail_in = zippedLength;
        zstream.avail_out = zstream.avail_in * 10;
        zstream.next_in = (Bytef*)zipped;
        char* const unzipped = malloc(zstream.avail_out);
        zstream.next_out = (Bytef*)unzipped;
        int const zstatus = inflateInit(&zstream);
        if (zstatus == Z_OK) {
            int const inflateStatus = inflate(&zstream, Z_FINISH);
            if (inflateStatus >= 0) {
                found = found || [BatchPDFParser findBatchNumberInChunk:unzipped needle:needle andAddTo:list];
            } else {
                NSLog(@"inflate() failed, error %d", inflateStatus);
            }
        } else {
            NSLog(@"Unable to initialize zlib, error %d", zstatus);
        }
        free(unzipped);
        inflateEnd(&zstream);

        int const cutLength = endPosition + strlen(streamStopMarker);
        [portion replaceBytesInRange:NSMakeRange(0, cutLength) withBytes:NULL length:0];
    }
    return found;
}

@end
