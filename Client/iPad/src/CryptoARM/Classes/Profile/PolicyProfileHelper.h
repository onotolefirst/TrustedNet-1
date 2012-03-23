//
//  PolicyProfileHelper.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CertUsage.h"
#import "DDXML.h"

@interface PolicyProfileHelper : NSObject

@property (nonatomic, retain) NSMutableDictionary *certPolicies;
@property (nonatomic, retain) NSMutableArray *currentPolicyOids;
@property (nonatomic, retain) NSString *currentPolicyId;
@property (nonatomic, retain) CertUsage *currentOid;
@property (nonatomic, retain) NSString *createSignature;
@property (nonatomic, retain) NSString *verifySignature;
@property (nonatomic, retain) NSString *dechipherParameters;
@property (nonatomic, retain) NSString *enchipherParameters;

@property (nonatomic, retain) NSArray *oidsForCreateSignature;
@property (nonatomic, retain) NSArray *oidsForVerifySignature;
@property (nonatomic, retain) NSArray *oidsForDechipherParameters;
@property (nonatomic, retain) NSArray *oidsForEnchipherParameters;


- (id)init;

- (void)startPolicy;
- (void)endPolicy;
- (void)startOid;
- (void)endOid;

- (DDXMLElement*)generateXmlBranch;

@end
