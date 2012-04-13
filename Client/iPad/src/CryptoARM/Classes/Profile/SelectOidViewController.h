//
//  SelectOidViewController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Profile.h"
#import "CommonDetailController.h"
#import "CertUsageHelper.h"

enum OID_SELECT_PAGE_TYPE {
    OSPT_SIGN_FILTER = 0,
    OSPT_ENCRYPT_FILTER = 1
    };

enum INDEXED_OID_IMAGES {
    IOI_UNCHECKED = 0,
    IOI_CHECKED = 1
    };

@interface SelectOidViewController : CommonDetailController <NavigationSource, UITableViewDataSource, UITableViewDelegate>
{
    CertUsageHelper *usagesHelper;
    
    NSMutableIndexSet *selectedIndex;
    
    NSMutableDictionary *images;
}

- (id)initWithProfile:(Profile *)profile andPageType:(enum OID_SELECT_PAGE_TYPE)pgType;

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, retain) Profile *parentProfile;

@property (readonly) enum OID_SELECT_PAGE_TYPE pageType;

- (void)actionForDoneButton;

@end
