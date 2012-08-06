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

@property (nonatomic, readonly) STORE *store;

- (STACK_OF(X509)*)x509Certificates;
@property (nonatomic, readonly) NSArray *certificates;

@property (readonly) enum CERT_STORE_TYPE storeType;

- (id)initWithStoreType:(enum CERT_STORE_TYPE)storeType;
//TODO: make ancestor class or protocol for supporting other store types
//initWithFileStore
//initWithAddressBook

- (void)addCertificate:(X509*)newCert;
- (void)removeCertificate:(X509*)removingCert;
//- (void)modifyCertificate:...

//- (void)addCRL:(X509_CRL*)newCrl;
+ (void)addCRL:(X509_CRL*)newCrl;
//- (void)removeCRL:...
//- (void)modidfyCRL:...

//- (void)addPrivateKey:...
- (void)removePrivateKeyById:(NSData*)privKeyId;
//- (void)modifyPrivateKey:...

+ (const char*)storeNameByTypeId:(enum CERT_STORE_TYPE)typeId;

@end
