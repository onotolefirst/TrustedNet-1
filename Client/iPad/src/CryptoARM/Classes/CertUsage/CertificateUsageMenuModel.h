//
//  CertificateUsageMenuModel.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CommonNavigationItem.h"

#import "CertUsageHelper.h"

@interface CertificateUsageMenuModel : CommonNavigationItem <MenuDataRefreshinProtocol>
{
    CertUsageHelper *usageHelper;
    NSString *savingFileName;
}

- (id)init;
- (void)dealloc;

@end
