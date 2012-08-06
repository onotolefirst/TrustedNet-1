//
//  PolicyProfileHelper.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PolicyProfileHelper.h"

#import "Utils.h"
#import "CertUsageHelper.h"
#import "XmlTags.h"

@implementation PolicyProfileHelper

@synthesize certPolicies;
@synthesize currentPolicyOids;
@synthesize currentPolicyId;
@synthesize currentOid;
@synthesize createSignature;
@synthesize verifySignature;
@synthesize dechipherParameters;
@synthesize enchipherParameters;

- (id)init
{
    self = [super init];
    if (self)
    {
        certPolicies = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return self;
}

- (void)startPolicy
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    self.currentPolicyOids = newArray;
    currentPolicyId = @"";
    [newArray release];
}

- (void)endPolicy;
{
    if( !(self.currentPolicyId) && !(self.currentPolicyId.length) )
    {
        NSLog(@"Unable save policy - ID is absent. Policy wrong formed in profile?");
        return;
    }
    
    [certPolicies setValue:self.currentPolicyOids forKey:self.currentPolicyId];
    self.currentPolicyId = @"";
    self.currentPolicyOids = nil;
}

- (void)startOid;
{
    CertUsage *newOid = [[CertUsage alloc] init];
    self.currentOid = newOid;
    [newOid release];
}

- (void)endOid;
{
    [currentPolicyOids addObject:self.currentOid];
    self.currentOid = nil;
}

- (NSArray*)oidsForCreateSignature
{
    if( !(self.createSignature) || !(self.createSignature.length) )
    {
        return nil;
    }
    
    return [self.certPolicies objectForKey:self.createSignature];
}

- (void)setOidsForCreateSignature:(NSArray*)oids
{
    if( self.createSignature &&  self.createSignature.length )
    {
        [self.certPolicies removeObjectForKey:self.createSignature];
    }
    
    self.createSignature = [Utils generateUUIDWithBraces:YES];
    NSArray *localRef = oids ? oids : [NSArray array];
    [self.certPolicies setValue:localRef forKey:self.createSignature];
}

- (NSArray*)oidsForVerifySignature
{
    if( !(self.verifySignature) || !(self.verifySignature.length) )
    {
        return nil;
    }
    
    return [self.certPolicies objectForKey:self.verifySignature];
}

- (void)setOidsForVerifySignature:(NSArray*)oids
{
    if( self.verifySignature &&  self.verifySignature.length )
    {
        [self.certPolicies removeObjectForKey:self.verifySignature];
    }
    
    self.verifySignature = [Utils generateUUIDWithBraces:YES];
    NSArray *localRef = oids ? oids : [NSArray array];
    [self.certPolicies setValue:localRef forKey:self.verifySignature];
}

- (NSArray*)oidsForDechipherParameters
{
    if( !(self.dechipherParameters) || !(self.dechipherParameters.length) )
    {
        return nil;
    }
    
    return [self.certPolicies objectForKey:self.dechipherParameters];
}

- (void)setOidsForDechipherParameters:(NSArray*)oids
{
    if( self.dechipherParameters &&  self.dechipherParameters.length )
    {
        [self.certPolicies removeObjectForKey:self.dechipherParameters];
    }
    
    self.dechipherParameters = [Utils generateUUIDWithBraces:YES];
    NSArray *localRef = oids ? oids : [NSArray array];
    [self.certPolicies setValue:localRef forKey:self.dechipherParameters];
}

- (NSArray*)oidsForEnchipherParameters
{
    if( !(self.enchipherParameters) || !(self.enchipherParameters.length) )
    {
        return nil;
    }
    
    return [self.certPolicies objectForKey:self.enchipherParameters];
}

- (void)setOidsForEnchipherParameters:(NSArray*)oids
{
    if( self.enchipherParameters &&  self.enchipherParameters.length )
    {
        [self.certPolicies removeObjectForKey:self.enchipherParameters];
    }
    
    self.enchipherParameters = [Utils generateUUIDWithBraces:YES];
    NSArray *localRef = oids ? oids : [NSArray array];
    [self.certPolicies setValue:localRef forKey:self.enchipherParameters];
}

- (void)addPolicyElementForId:(NSString*)policyId withTag:(NSString*)tagName toBranch:(DDXMLElement*)rootBranch
{
    DDXMLElement *policyElement = [[DDXMLElement alloc] initWithName:tagName];
    
    if( policyId )
    {
        DDXMLElement *usePolicy = [[DDXMLElement alloc] initWithName:TAG_USE_POLICY];
        usePolicy.stringValue = policyId;
        [policyElement addChild:usePolicy];
        [usePolicy release];
    }
    
    [rootBranch addChild:policyElement];
    
    [policyElement release];
}

- (DDXMLElement*)generateXmlBranch
{
    DDXMLElement *policyProfileRoot = [[DDXMLElement alloc] initWithName:TAG_POLICY_PROFILE];
    
    DDXMLElement *certificatsPolicies = [DDXMLElement elementWithName:TAG_CERTIFICATE_POLICIES];
    [self.certPolicies enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSString *stringKey = (NSString*)key;
        NSArray *oids = (NSArray*)obj;
        
        if( !stringKey || !oids )
        {
            return;
        }
        
        DDXMLElement *policyElement = [[DDXMLElement alloc] initWithName:TAG_POLICY];
        [policyElement addChild:[DDXMLElement elementWithName:TAG_POLICY_ID stringValue:stringKey]];
        
        DDXMLElement *ekuElement = [DDXMLElement elementWithName:TAG_EKU];
        for (CertUsage *curentUsage in oids)
        {
            [ekuElement addChild:[curentUsage contructXmlBranch]];
        }
        [policyElement addChild:ekuElement];
        
        [certificatsPolicies addChild:policyElement];
        [policyElement release];
    }];
    
    [policyProfileRoot addChild:certificatsPolicies];
    
    [self addPolicyElementForId:self.createSignature withTag:TAG_NEW_SIGNATURE toBranch:policyProfileRoot];
    [self addPolicyElementForId:self.verifySignature withTag:TAG_VERIFY_SIGNATURE toBranch:policyProfileRoot];
    [self addPolicyElementForId:self.dechipherParameters withTag:TAG_DECHIPHER_PARAMETERS toBranch:policyProfileRoot];
    [self addPolicyElementForId:self.enchipherParameters withTag:TAG_ENCHIPHER_PARAMETERS toBranch:policyProfileRoot];
    
    return [policyProfileRoot autorelease];
}

@end
