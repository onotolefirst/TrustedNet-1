//
//  CertStoreViewController.h
//  CryptoARM
//
//  Created by Денис Бурдин on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "../Crypto/Crypto.h"
#import "../Utils/Utils.h"
#import "../Crypto/Certificate.h"
#import "DetailNavController.h"
#import "CertificateStoreCellView.h"
#import "AddressBook/AddressBook.h"
#import "AddressBookCertificateBindingManager.h"
#import "CertDetailViewController.h"

#include "time.h"
#include <Openssl/bio.h>
#include <Openssl/sha.h>
#include <Openssl/x509.h>
#include <Openssl/safestack.h>
#include <Openssl/asn1.h>
#include <Openssl/ctiosrsa.h>
#include <Openssl/store.h>

@interface CertStoreViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NavigationSource,UITextFieldDelegate>
{
    DetailNavController *parentController;
    UIBarButtonItem *saveButton;
    bool isShowingLandscapeView;
    UITableView *tblCerts;
    STACK_OF(X509) *skUnattachedCerts;
    STACK_OF(X509) *skPersonCerts;
    STACK_OF(X509) *skAllPresentedCerts;
    ABRecordRef selectedPerson;
}

@property (nonatomic, assign) bool isShowingLandscapeView;
@property (nonatomic, assign) UIBarButtonItem *saveButton;
@property (nonatomic, assign) DetailNavController *parentController;
@property (nonatomic, assign) IBOutlet UITableView *tblCerts;
@property (nonatomic, assign) ABRecordRef selectedPerson;

- (id)initWithNibName:(NSString *)nibNameOrNil andPerson:(ABRecordRef)selectedPerson bundle:(NSBundle *)nibBundleOrNil;

@end

