//
//  CheckStatusDialogViewController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 18.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Certificate.h"
#import "CheckStatusDialogViewControllerDelegate.h"

// Bit flags
enum CERT_CHECK_TYPE {
    CCT_LOCAL_CRL_ONLY = 0,
    CCT_ONLINE_CRL = 1
    };

@interface CheckStatusDialogViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    enum CERT_CHECK_TYPE certCheckType;
}

@property (nonatomic, retain) CertificateInfo *certForVerifying;
@property (nonatomic, retain) id<CheckStatusDialogViewControllerDelegate> delegate;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *dialogTitleItem;

- (id)initWithCertificate:(CertificateInfo*)cert;

- (IBAction)actionForButtonCancel:(id)sender;
- (IBAction)actionForButtonDone:(id)sender;

@end
