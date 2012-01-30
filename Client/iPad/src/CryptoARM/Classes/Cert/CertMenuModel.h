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

@interface CertMenuModel : CommonNavigationItem {
    STACK_OF(X509) *certArray;
}

- (id) initWithStoreName:(NSString *)strStoreName;

@end
