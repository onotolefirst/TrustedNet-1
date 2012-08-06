//
//  ProfileHelper.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Profile.h"
#import "PolicyProfileHelper.h"

@interface ProfileHelper : NSObject <NSXMLParserDelegate>
{
    NSMutableArray *tagStack;
    Profile *parsingProfile;

    NSMutableString *parsingDataAccumulator;
    PolicyProfileHelper *parsingPolicyProfile;
}

@property (nonatomic, retain) NSMutableArray *profiles;
@property (nonatomic, retain) NSString *storageFile;

- (id)initEmpty;
- (id)initWithStorageFile:(NSString*)storageFile;

- (BOOL)addProfile:(Profile*)newProfile;
- (BOOL)removeProfileWithId:(NSString*)removingId;

- (BOOL)checkIfExistsProfileWithId:(NSString*)profileId;

- (void)readStorage;
- (void)readStorage:(NSString*)storageFileName;

- (void)writeStorage;
- (void)writeStorage:(NSString*)storageFileName;

@end
