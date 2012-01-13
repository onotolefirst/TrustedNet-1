//
//  AddressBookCertificateBindingManager.h
//  CryptoARM
//
//  Created by Денис Бурдин on 22.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "AddressBook/AddressBook.h"
#import "../Crypto/Crypto.h"
#import "../Utils/Utils.h"
#import "../Crypto/Certificate.h"
#import "../Cert/CertStoreViewController.h"
#import "DetailNavController.h"
#import "RecipientCertificateCellView.h"
#import "AdvancedAddressBookViewController.h"

#include "time.h"
#include <Openssl/bio.h>
#include <Openssl/sha.h>
#include <Openssl/x509.h>
#include <Openssl/safestack.h>
#include <Openssl/asn1.h>
#include <Openssl/ctiosrsa.h>
#include <Openssl/store.h>

@interface AddressBookCertificateBindingManager : UIViewController<UITableViewDataSource,UITableViewDelegate,NavigationSource,UITextFieldDelegate>
{
    DetailNavController *parentController;
    UIBarButtonItem *saveButton;
    bool isShowingLandscapeView;
    UITableView *tblRecipients;
    UILabel *lblOrganization;
    UILabel *lblOrganizationValue;
    UILabel *lblPost;
    UILabel *lblPostValue;
    UILabel *lblEmail;
    UILabel *lblEmailValue;
    UILabel *lblFullPersonName;
    UINavigationBar *navDocRecipList;
    UIBarButtonItem *btnAddCertificate;
    ABRecordRef selectedPerson;
    UIImageView *imgUser;
    STACK_OF(X509) *skCertFound;
    X509 *selectedCellCert; // selected certificate(marked with tick) used for enciphering
}

@property (nonatomic, assign) bool isShowingLandscapeView;
@property (nonatomic, assign) ABRecordRef selectedPerson;
@property (nonatomic, retain) IBOutlet UITableView *tblRecipients;
@property (nonatomic, retain) IBOutlet UILabel *lblOrganization;
@property (nonatomic, retain) IBOutlet UILabel *lblOrganizationValue;
@property (nonatomic, retain) IBOutlet UILabel *lblPost;
@property (nonatomic, retain) IBOutlet UILabel *lblPostValue;
@property (nonatomic, retain) IBOutlet UILabel *lblEmail;
@property (nonatomic, retain) IBOutlet UILabel *lblEmailValue;
@property (nonatomic, retain) IBOutlet UILabel *lblFullPersonName;
@property (nonatomic, retain) IBOutlet UINavigationBar *navDocRecipList;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnAddCertificate;
@property (nonatomic, retain) IBOutlet UIImageView *imgUser;

- (void)saveButtonAction:(id)sender;
- (void)showCertificate:(id)sender;
- (void)removeCertificate:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil andPerson:(ABRecordRef)personRecord bundle:(NSBundle *)nibBundleOrNil;
- (void)addCertificate;
- (void)updateCertList:(STACK_OF(X509) *)skNewCertList;

@end
