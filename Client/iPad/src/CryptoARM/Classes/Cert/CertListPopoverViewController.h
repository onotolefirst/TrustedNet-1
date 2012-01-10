//
//  CertListPopoverViewController.h
//  CryptoARM
//
//  Created by Денис Бурдин on 12.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressBook/AddressBook.h"
#import "../Crypto/Crypto.h"
#import "../Utils/Utils.h"
#import "../Crypto/Certificate.h"
#import "CertCellView.h"

#include "time.h"
#include <Openssl/bio.h>
#include <Openssl/sha.h>
#include <Openssl/x509.h>
#include <Openssl/safestack.h>
#include <Openssl/asn1.h>
#include <Openssl/ctiosrsa.h>
#include <Openssl/store.h>

@interface CertListPopoverViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *menuTable;
    ABMutableMultiValueRef m_certListURL;
    STACK_OF(X509) *skPersonCerts;
    UIPopoverController *personCertificatesMenuPopover;
    ABRecordRef selectedPerson;
}

@property (nonatomic, retain) UITableView *menuTable;
@property (nonatomic, assign) ABRecordRef selectedPerson;
@property (nonatomic, retain) UIPopoverController *personCertificatesMenuPopover;

//- (void)applyMenuSource:(SystemSettingsMenu*)source;
- (CGFloat)calculateMenuHeight;
- (id)initWithCertListURL:(ABMutableMultiValueRef)certListURL;

@end
