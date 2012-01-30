//
//  CertChainViewController.h
//  CryptoARM
//
//  Created by Денис Бурдин on 20.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CertCellView.h"
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

@interface CertChainViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{    
    UITableView *menuTable;
    UIPopoverController *chainMenuPopover;
    X509 *cert;
    STACK_OF(X509) *stCertChain;
}

@property(nonatomic, retain) UITableView *menuTable;
@property(nonatomic, retain) UIPopoverController *chainMenuPopover;

- (CGFloat)calculateMenuHeight;
- (void)setPopoverController:(UIPopoverController *)controller;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andCert:(X509 *)someCert;

@end
