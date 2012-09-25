//
//  AdvancedAddressBookViewController.h
//  CryptoARM
//
//  Created by Денис Бурдин on 06.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "../Crypto/Crypto.h"
#import "../Utils/Utils.h"
#import "../Crypto/Certificate.h"
#import "DetailNavController.h"
#import "RecipientCellView.h"
#import "../Detail/SystemSettingsMenuViewController.h"
#import "AddressBook/AddressBook.h"
#import "../Cert/CertListPopoverViewController.h"

#include "time.h"
#include <Openssl/bio.h>
#include <Openssl/sha.h>
#include <Openssl/x509.h>
#include <Openssl/safestack.h>
#include <Openssl/asn1.h>
#include <Openssl/ctiosrsa.h>
#include <Openssl/store.h>

@interface AdvancedAddressBookViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NavigationSource,UITextFieldDelegate>
{
    DetailNavController *parentController;
    UIBarButtonItem *groupsButton;
    UIBarButtonItem *saveButton;
    UIPopoverController *groupsPopover;
    bool isShowingLandscapeView;
    UITableView *tblRecipients;
    NSArray *people;
    UIPopoverController *personCertificatesMenuPopover;
    CGRect rectCellBtn;
}

@property (nonatomic, assign) bool isShowingLandscapeView;
@property (nonatomic, assign) CGRect rectCellBtn;
@property (nonatomic, retain) IBOutlet UITableView *tblRecipients;
@property (nonatomic, retain) NSArray *people;
@property (nonatomic, retain) UIPopoverController *personCertificatesMenuPopover;

- (void)groupsButtonAction:(id)sender;
- (void)saveButtonAction:(id)sender;
- (void)performSelectorOnCellButton:(id)sender;
- (void)reloadTableView;

@end
