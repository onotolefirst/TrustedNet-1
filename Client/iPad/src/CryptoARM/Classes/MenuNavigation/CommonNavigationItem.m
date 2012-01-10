//
//  CommonNavigationItem.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommonNavigationItem.h"

@implementation CommonNavigationItem

- (NSInteger)mainMenuSections
{
    return 1;
}

- (NSInteger)mainMenuRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCellAccessoryType)typeOfElementAt:(NSIndexPath *)idx
{
    return UITableViewCellAccessoryNone;
}

- (UITableViewCell*)dequeOrCreateDefaultCell:(UITableView*)tableView
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    return cell;
}

- (UITableViewCell*)fillCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)idx inTableView:(UITableView*)tableView
{
    cell.textLabel.text = @"Warning! Wrong object!";
    return cell;
}

-(CommonNavigationItem*)submenuNavigationItemForIndex:(NSIndexPath*)indexPath
{
    return nil;
}

- (UIViewController<NavigationSource>*)getDetailControllerForElementAt:(NSIndexPath*)index
{
    return nil;
}

- (CGFloat)cellHeight:(NSIndexPath *)indexPath
{
    return 44; // default cell row height size
}

- (BOOL)showAddButton;
{
    return NO;
}

- (UIViewController<NavigationSource>*)createControllerForNewElement
{
    return nil;
}

@end
