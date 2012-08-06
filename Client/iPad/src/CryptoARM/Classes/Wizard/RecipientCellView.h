//
//  RecipientCellView.h
//  CryptoARM
//
//  Created by Денис Бурдин on 17.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Crypto/Certificate.h"

@interface RecipientCellView : UITableViewCell
{
    UIImageView *imgUser;
    UIImageView *imgCert;
    UILabel *lblUserName;
    UILabel *lblOrganization;
    UILabel *lblPost;
    UILabel *lblNumberOfBoundCerts;
    UILabel *lblCertIssuer;
    UILabel *lblValidTo;
    UIButton *btnAddOrRemoveRecipient;
    CertificateInfo *cert; // TODO: maybe cert array OR address book structure item
}

@property (nonatomic, retain) IBOutlet UIImageView *imgUser;
@property (nonatomic, retain) IBOutlet UIImageView *imgCert;
@property (nonatomic, retain) IBOutlet UILabel *lblPost;
@property (nonatomic, retain) IBOutlet UILabel *lblNumberOfBoundCerts;
@property (nonatomic, retain) IBOutlet UILabel *lblValidTo;
@property (nonatomic, retain) IBOutlet UILabel *lblCertIssuer;
@property (nonatomic, retain) IBOutlet UILabel *lblOrganization;
@property (nonatomic, retain) IBOutlet UILabel *lblUserName;
@property (nonatomic, retain) IBOutlet UIButton *btnAddOrRemoveRecipient;
@property (nonatomic, retain) CertificateInfo *cert;

@end
