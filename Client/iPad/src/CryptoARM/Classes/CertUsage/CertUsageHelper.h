//
//  CertUsageHelper.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CertUsage.h"
#import "XmlTags.h"

@interface CertUsageHelper : NSObject <NSXMLParserDelegate>
{
    NSMutableArray* certUsages;
    
    CertUsage *curUsage;
    enum oids_tag_type curTagType;
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
