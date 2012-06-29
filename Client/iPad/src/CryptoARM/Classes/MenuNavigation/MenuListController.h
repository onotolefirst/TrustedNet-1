//
//  MenuListController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CommonNavigationItem.h"
#import "MenuNavigationDelegate.h"
#import "MenuNavigationController.h"
#import "ArchiveMenuModel.h"

@interface MenuListController : UITableViewController <UISearchDisplayDelegate>
{
    UISearchBar *searchBar;
    UISearchDisplayController *searchController;
    MainSplitViewController *mainSplitView;
}

@property (nonatomic, retain) MainSplitViewController *mainSplitView;
@property (nonatomic, retain) id<MenuNavigationDelegate> navigationDelegate;

- (id)initWithMenuItem:(CommonNavigationItem*)menuItem andSplitViewController:(MainSplitViewController *)svc;

@property (retain, nonatomic) CommonNavigationItem *menuModel;
@property (nonatomic, readonly) UITableView *currentTableView;

@end
