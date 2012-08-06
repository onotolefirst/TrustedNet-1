//
//  FileItemCellView.h
//  CryptoARM
//
//  Created by Денис Бурдин on 17.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Crypto/Certificate.h"
#include <Openssl/bio.h>
#include <Openssl/sha.h>
#include <Openssl/x509.h>
#include <Openssl/safestack.h>
#include <Openssl/asn1.h>
#include <Openssl/ctiosrsa.h>
#include <Openssl/store.h>

@interface FileItemCellView : UITableViewCell
{
    UILabel *title;
    UILabel *creationDate;
    UILabel *size;
    UILabel *typeOrContent;
    UIImageView *docImageView;
    UIButton *btnTick;
    NSString *fullFilePath;
    bool checked; // for multiple select certificates, should be changed only in user defined code
}

@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *creationDate;
@property (nonatomic, retain) IBOutlet UILabel *size;
@property (nonatomic, retain) IBOutlet UILabel *typeOrContent;
@property (nonatomic, retain) IBOutlet UIImageView *docImageView;
@property (nonatomic, retain) IBOutlet UIButton *btnTick;
@property (nonatomic, retain) NSString *fullFilePath;
@property (nonatomic, assign) bool checked;

@end
