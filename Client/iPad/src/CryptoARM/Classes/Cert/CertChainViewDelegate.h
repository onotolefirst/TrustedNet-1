//
//  CertChainViewDelegate.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 12.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Certificate.h"

@protocol CertChainViewDelegate <NSObject>

- (void)pushCert:(CertificateInfo*)cert;

@end
