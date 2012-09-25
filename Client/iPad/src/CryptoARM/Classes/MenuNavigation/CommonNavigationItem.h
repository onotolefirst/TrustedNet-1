//
//  CommonNavigationItem.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NavigationSource.h"

@interface CommonNavigationItem : NSObject {
    UIView *tblHeaderView;
}

@property (nonatomic, retain) UIView *tblHeaderView;

- (NSString*)menuTitle;

- (NSInteger)mainMenuSections;
- (NSInteger)mainMenuRowsInSection:(NSInteger)section;

- (UITableViewCell*)dequeOrCreateDefaultCell:(UITableView*)tableView;
- (UITableViewCell*)fillCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)idx inTableView:(UITableView*)tableView;
- (CommonNavigationItem*)submenuNavigationItemForIndex:(NSIndexPath*)indexPath;
- (UIViewController<NavigationSource>*)getDetailControllerForElementAt:(NSIndexPath*)index;

- (CGFloat)cellHeight:(NSIndexPath *)indexPath;

- (BOOL)showAddButton;
- (UIViewController<NavigationSource>*)createControllerForNewElement;

@property BOOL filtered;

- (BOOL)filterable;
- (NSArray*)dataScopes;
- (void)applyFilterForSeachText:(NSString*)searchString andScope:(NSInteger)searchScope;

@end