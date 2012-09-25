//
//  CertificateStoreCellView.m
//  CryptoARM
//
//  Created by Денис Бурдин on 17.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CertificateStoreCellView.h"

@implementation CertificateStoreCellView
@synthesize imgTick, imgCert, lblValidTo, lblCertIssuer, lblSubject, btnShowCert, cert, isChecked;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        isChecked = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)dealloc
{
    [imgTick release];
    [imgCert release];
    [lblValidTo release];
    [lblCertIssuer release];
    [lblSubject release];
    [btnShowCert release];
    [cert release];

    [super dealloc];
}

@end
