//
//  CertificateStore.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Crypto.h"

enum CERT_STORE_TYPE {
    CST_MY = 0,
    CST_ADDRESS_BOOK = 1,
    CST_CA = 2,
    CST_ROOT = 3,
    
    CST_DEVICE_ADDRESS_BOOK = 10,
    CST_FILE_PFX = 11
    //,CST_FILE_SST = 12
    };

@interface CertificateStore : NSObject
{
    ENGINE *e;
    STORE *store;
}

- (STACK_OF(X509)*)x509Certificates;
@property (nonatomic, readonly) NSArray *certificates;

@property (readonly) enum CERT_STORE_TYPE storeType;

- (id)initWithStoreType:(enum CERT_STORE_TYPE)storeType;
//initWithFileStore
//initWithAddressBook

- (void)addCertificate:(X509*)newCert;
- (void)removeCertificate:(X509*)removingCert;
//- (void)modifyCertificate:...

+ (const char*)storeNameByTypeId:(enum CERT_STORE_TYPE)typeId;

@end
