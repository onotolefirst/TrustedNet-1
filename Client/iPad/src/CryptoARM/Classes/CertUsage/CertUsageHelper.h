//
//  CertUsageHelper.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CertUsage.h"

#define TAG_OIDS @"OIDs"
#define TAG_OID @"OID"
#define TAG_VALUE @"Value"
#define TAG_FRND_NAME @"FriendlyName"

enum tag_type {
    TT_NONE = 0,
    TT_OIDS = 1,
    TT_OID = 2,
    TT_VALUE = 3,
    TT_FRND_NAME = 4
    };

@interface CertUsageHelper : NSObject <NSXMLParserDelegate>
{
    NSMutableArray* certUsages;
    
    CertUsage *curUsage;
    enum tag_type curTagType;
}

- (id)init;
- (id)initWithDictionary:(NSString*)dictionaryFileName;
- (void)dealloc;
- (void)addUsage:(CertUsage*)usage;
- (void)removeUsageWithId:(NSString*)usageId;
- (CertUsage*)checkUsageWithId:(NSString*)usageId;

- (BOOL)readUsages:(NSString*)fileNme;
- (void)writeUsages:(NSString*)fileName;

- (void)sortUsages;

@property (nonatomic, readonly) NSMutableArray *certUsages;

@end
