//
//  RecipientCellView.m
//  CryptoARM
//
//  Created by Денис Бурдин on 17.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RecipientCellView.h"

@implementation RecipientCellView
@synthesize imgUser, imgCert, lblPost, lblNumberOfBoundCerts, lblValidTo, lblCertIssuer, lblOrganization, lblUserName, btnAddOrRemoveRecipient, cert;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [imgUser release];
    [imgCert release];
    [lblPost release];
    [lblNumberOfBoundCerts release];
    [lblValidTo release];
    [lblCertIssuer release];
    [lblOrganization release];
    [lblUserName release];
    [btnAddOrRemoveRecipient release];
    
    [super dealloc];
}

@end
