//
//  CertificateUsageMenuModel.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CertificateUsageMenuModel.h"

#import "CertUsageViewController.h"
#import "../CommonPaths.h"

@implementation CertificateUsageMenuModel

- (id)init
{
    self = [super init];
    if(self)
    {
        savingFileName = [[NSString alloc] initWithFormat:@"%@%@", PATH_OPERATIONAL_SETTINGS, FILENAME_CERTIFICATE_USAGES];
        usageHelper = [[CertUsageHelper alloc] initWithDictionary:savingFileName];
    }
    return self;
}

- (void)dealloc
{
    if( usageHelper )
    {
        [usageHelper release];
        [savingFileName release];
    }
    
    [super dealloc];
}

#pragma mark - superclass CommonNavigationItem methods overloading

//- (NSInteger)mainMenuSections
//{
//    return 1;
//}

- (NSInteger)mainMenuRowsInSection:(NSInteger)section
{
    return [usageHelper.certUsages count];
}

- (UITableViewCellAccessoryType)typeOfElementAt:(NSIndexPath *)idx
{
    return UITableViewCellAccessoryDetailDisclosureButton;
}

- (UITableViewCell*)dequeOrCreateDefaultCell:(UITableView*)tableView
{
    static NSString *CellIdentifier = @"CertUsageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    return cell;
}

- (UITableViewCell*)fillCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)idx inTableView:(UITableView*)tableView
{
    cell.textLabel.text = ((CertUsage*)[usageHelper.certUsages objectAtIndex:idx.row]).usageId;
    cell.detailTextLabel.text = ((CertUsage*)[usageHelper.certUsages objectAtIndex:idx.row]).usageDescription; 
    cell.imageView.image = [UIImage imageNamed:@"OID.png"];
    return cell;
}

-(CommonNavigationItem*)submenuNavigationItemForIndex:(NSIndexPath*)indexPath
{
    return nil;
}

- (UIViewController<NavigationSource>*)getDetailControllerForElementAt:(NSIndexPath*)index
{
    return [[[CertUsageViewController alloc] initWithUsage:[[[usageHelper.certUsages objectAtIndex:index.row] copy] autorelease] idLabel:nil descriptionLabel:nil] autorelease];
}

- (CGFloat)cellHeight:(NSIndexPath *)indexPath
{
    return 44; // default cell row height size
}

- (BOOL)showAddButton
{
    return YES;
}

- (UIViewController<NavigationSource>*)createControllerForNewElement
{
    CertUsage *newUsage = [[CertUsage alloc] initWithId:@"" andDescription:@""];
    CertUsageViewController *addingController = [[[CertUsageViewController alloc] initWithUsage:newUsage idLabel:nil descriptionLabel:nil]autorelease];
    [newUsage release];
    return addingController;
}

#pragma mark - MenuDataRefreshinProtocol

- (void)addElement:(id)newElement
{
    if( ![newElement isKindOfClass:[CertUsage class]] )
    {
        NSLog(@"Wrong class transmitted");
        return;
    }
    
    [usageHelper addUsage:newElement];
    [usageHelper writeUsages:savingFileName];
}

- (void)removeElement:(id)removingElement
{
    if( ![removingElement isKindOfClass:[CertUsage class]] )
    {
        NSLog(@"Wrong class transmitted");
        return;
    }
    
    [usageHelper removeUsageWithId:((CertUsage*)removingElement).usageId];
    [usageHelper writeUsages:savingFileName];
}

- (void)saveExistingElement:(id)savingElement
{
    if( ![savingElement isKindOfClass:[CertUsage class]] )
    {
        NSLog(@"Wrong class transmitted");
        return;
    }
    
    [usageHelper removeUsageWithId:((CertUsage*)savingElement).usageId];
    [usageHelper addUsage:savingElement];
    [usageHelper writeUsages:savingFileName];
}

- (BOOL)checkIfExisting:(id)checkingElement
{
    CertUsage *checkingUsage = (CertUsage*)checkingElement;
    return [usageHelper checkUsageWithId:checkingUsage.usageId] != nil;
}

@end
