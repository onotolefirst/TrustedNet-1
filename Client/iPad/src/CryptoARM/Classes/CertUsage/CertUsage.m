//
//  CertUsage.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CertUsage.h"

#import "XmlTags.h"

@implementation CertUsage

@synthesize usageId;
@synthesize usageDescription;

+ (CertUsage*)createUsageWithId:(NSString*)usgId andDescription:(NSString*)usgDescr
{
    return [[[CertUsage alloc] initWithId:usgId andDescription:usgDescr] autorelease];
}

- (id)initWithId:(NSString*)usgId andDescription:(NSString*)usgDescr
{
    self = [super init];
    if(self)
    {
        self.usageId = usgId;
        self.usageDescription = usgDescr;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[CertUsage allocWithZone:zone] initWithId:[self usageId] andDescription:[self usageDescription]];
}

- (DDXMLElement*)contructXmlBranch
{
    if( !self.usageId )
    {
        return nil;
    }
    
    DDXMLElement *oidRoot = [DDXMLElement elementWithName:TAG_OID];
    
    [oidRoot addChild:[DDXMLElement elementWithName:TAG_VALUE stringValue:self.usageId]];
    [oidRoot addChild:[DDXMLElement elementWithName:TAG_FRND_NAME stringValue:self.usageDescription ? self.usageDescription : @""]];
    
    return oidRoot;
}

@end
