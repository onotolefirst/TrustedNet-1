//
//  SelectAlgorithm.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommonDetailController.h"

#import "Profile.h"

enum ALG_PAGE_TYPE {
    APT_SIGN_HASH = 1 //,
//    APT_ENCRYPR_ALG = 2
    };

@interface SelectAlgorithm : CommonDetailController <NavigationSource, UITableViewDataSource, UITableViewDelegate>

- (id)initWithParentProfile:(Profile*)profileFromParent andPageType:(enum ALG_PAGE_TYPE)newPageType;

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, retain) Profile *parentProfile;
@property (readonly) enum ALG_PAGE_TYPE pageType;

@property (nonatomic, retain) NSArray *algList;

@end
