//
//  CertDetailHeaderViewController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 02.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CertificateStore.h"

@interface CertDetailHeaderViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    int currentCertStatus;
}

- (id)initWithCert:(CertificateInfo*)certForInit;

@property (retain, nonatomic) IBOutlet UIImageView *statusImage;
@property (retain, nonatomic) IBOutlet UITableView *headerTable;

@property (nonatomic, readonly) CertificateInfo *cert;
@property (nonatomic, retain) CertificateStore *store;

@property (nonatomic, retain) NSString *keyIdentifier;

- (void)updateCertStatus;
- (void)updateCertStatus:(int)certStatus;

@end
