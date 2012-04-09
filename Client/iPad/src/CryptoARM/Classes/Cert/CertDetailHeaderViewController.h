//
//  CertDetailHeaderViewController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 02.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Certificate.h"
#import "CertificateStore.h"

@interface CertDetailHeaderViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithCert:(CertificateInfo*)certForInit;

@property (retain, nonatomic) IBOutlet UIImageView *statusImage;
@property (retain, nonatomic) IBOutlet UITableView *headerTable;

@property (nonatomic, readonly) CertificateInfo *cert;
//TODO: is this property required?
@property (nonatomic, retain) CertificateStore *store;

@property (nonatomic, retain) NSString *keyIdentifier;

- (NSInteger)getCertStatus;
- (NSString*)getCertStatusDescription;

@end
