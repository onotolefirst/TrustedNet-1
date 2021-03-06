//
//  CertMenuModel.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonNavigationItem.h"
#import "CertCellView.h"
#import "CertDetailViewController.h"
#import "../Crypto/Crypto.h"
#import "../Utils/Utils.h"
#import "../Crypto/Certificate.h"

#include "time.h"
#include <Openssl/bio.h>
#include <Openssl/sha.h>
#include <Openssl/x509.h>
#include <Openssl/safestack.h>
#include <Openssl/asn1.h>
#include <Openssl/ctiosrsa.h>
#include <Openssl/store.h>

#include "CertificateStore.h"

@interface CertMenuModel : CommonNavigationItem <MenuDataRefreshinProtocol>

@property (nonatomic, retain) CertificateStore *store;
@property (nonatomic, retain) NSArray *certArray;

- (id) initWithStoreType:(enum CERT_STORE_TYPE)initType;
- (id) initWithStore:(CertificateStore*)newStore;

@end
