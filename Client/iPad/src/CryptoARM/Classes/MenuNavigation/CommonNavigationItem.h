//
//  CommonNavigationItem.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NavigationSource.h"


@interface CommonNavigationItem : UINavigationItem {
}

- (NSInteger)mainMenuSections;
- (NSInteger)mainMenuRowsInSection:(NSInteger)section;
- (UITableViewCellAccessoryType)typeOfElementAt:(NSIndexPath*)idx;

- (UITableViewCell*)dequeOrCreateDefaultCell:(UITableView*)tableView;
- (UITableViewCell*)fillCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)idx inTableView:(UITableView*)tableView;
- (CommonNavigationItem*)submenuNavigationItemForIndex:(NSIndexPath*)indexPath;
- (UIViewController<NavigationSource>*)getDetailControllerForElementAt:(NSIndexPath*)index;

- (CGFloat)cellHeight:(NSIndexPath *)indexPath;

- (BOOL)showAddButton;
- (UIViewController<NavigationSource>*)createControllerForNewElement;

@end
