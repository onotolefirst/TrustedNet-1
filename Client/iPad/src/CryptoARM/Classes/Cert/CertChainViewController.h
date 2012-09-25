//
//  CertChainViewController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 11.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CertChainViewDelegate.h"

enum CHAIN_IMAGES_PROPERTIES {
    CIP_PERSONAL = 1,
    CIP_OTHER = 2,
    CIP_INTERMEDIATE = 4,
    CIP_ROOT = 5,
    
    CIP_VALID = 16,
    CIP_INSUFFICIENT_INFO = 32,
    CIP_INVALID = 64,
    
    CIP_WITH_CHAIN_CONNECTOR = 128
    };

@interface CertChainViewController : UITableViewController
{
    NSMutableDictionary *indexedImages;
}

- (id)initWithCertificate:(CertificateInfo*)cert;

- (NSArray*)buildChainForCert:(CertificateInfo*)cert;
- (void)setPopoverContentSize:(UIPopoverController*)parentPopover;

@property (nonatomic, retain) NSArray *certChain;

@property (nonatomic, retain) id<CertChainViewDelegate> delegate;

- (UIImage*)getImageForElementType:(int)elementType;

@end
