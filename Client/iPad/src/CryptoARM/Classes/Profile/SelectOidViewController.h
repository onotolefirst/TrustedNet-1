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

@interface SelectOidViewController : CommonDetailController <NavigationSource, UITableViewDataSource, UITableViewDelegate>
{
    CertUsageHelper *usagesHelper;
    
    NSMutableIndexSet *selectedIndex;
    
    UIImage *checkedOid;
    UIImage *uncheckedOid;
}

- (id)initWithProfile:(Profile *)profile;

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, retain) Profile *parentProfile;

- (void)actionForDoneButton;

@end
