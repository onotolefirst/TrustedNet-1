//
//  CertUsage.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CertUsage : NSObject <NSCopying>

+ (CertUsage*)createUsageWithId:(NSString*)usgId andDescription:(NSString*)usgDescr;

- (id)initWithId:(NSString*)usgId andDescription:(NSString*)usgDescr;

@property (nonatomic, retain) NSString *usageId;
@property (nonatomic, retain) NSString *usageDescription;

@end
