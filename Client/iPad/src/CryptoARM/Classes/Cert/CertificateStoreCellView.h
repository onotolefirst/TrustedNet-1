//
//  CertificateStoreCellView.h
//  CryptoARM
//
//  Created by Денис Бурдин on 17.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Crypto/Certificate.h"
#include <Openssl/bio.h>
#include <Openssl/sha.h>
#include <Openssl/x509.h>
#include <Openssl/safestack.h>
#include <Openssl/asn1.h>
#include <Openssl/ctiosrsa.h>
#include <Openssl/store.h>

@interface CertificateStoreCellView : UITableViewCell
{
    UIImageView *imgTick;
    UIImageView *imgCert;
    UILabel *lblSubject;
    UILabel *lblCertIssuer;
    UILabel *lblValidTo;
    UIButton *btnShowCert;
    CertificateInfo *cert;
    bool isChecked;
}

@property (nonatomic, retain) IBOutlet UIImageView *imgTick;
@property (nonatomic, retain) IBOutlet UIImageView *imgCert;
@property (nonatomic, retain) IBOutlet UILabel *lblSubject;
@property (nonatomic, retain) IBOutlet UILabel *lblValidTo;
@property (nonatomic, retain) IBOutlet UILabel *lblCertIssuer;
@property (nonatomic, retain) IBOutlet UIButton *btnShowCert;
@property (nonatomic, retain) CertificateInfo *cert;
@property (nonatomic, assign) bool isChecked;

@end
