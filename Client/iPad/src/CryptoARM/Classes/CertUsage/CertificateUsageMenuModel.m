//
//  CertificateUsageMenuModel.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CertificateUsageMenuModel.h"

#import "CertUsageViewController.h"
#import "PathHelper.h"

@implementation CertificateUsageMenuModel

- (id)init
{
    self = [super init];
    if(self)
    {
        savingFileName = [[NSString stringWithFormat:@"%@/%@", [PathHelper getOperationalSettinsDirectoryPath], [PathHelper getCertUsagesFileName]] copy];
        
        usageHelper = [[CertUsageHelper alloc] initWithDictionary:savingFileName];
        
        filteredUsages = [[NSMutableArray alloc] init];
        
        self.filtered = NO;
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
    [filteredUsages release];
    
    [super dealloc];
}

#pragma mark - superclass CommonNavigationItem methods overloading

- (NSString*)menuTitle
{
    return NSLocalizedString(@"CERTIFICATE_USAGES_DICTIONARY", @"Справочник назначений сертификата");
}

- (NSInteger)mainMenuRowsInSection:(NSInteger)section
{
    NSInteger result = self.filtered ? filteredUsages.count : usageHelper.certUsages.count;
    return result;
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
    if( (self.filtered ? filteredUsages.count : usageHelper.certUsages.count) < idx.row )
    {
        NSLog(@"Error: requested index is outbond. Maybe wrong array requested");
        return cell;
    }
    
    CertUsage *resultingUsage = (CertUsage*)(self.filtered ? [filteredUsages objectAtIndex:idx.row] : [usageHelper.certUsages objectAtIndex:idx.row]);
    
    cell.textLabel.text = resultingUsage.usageId;
    cell.detailTextLabel.text = resultingUsage.usageDescription;
    
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.detailTextLabel.numberOfLines = 2;
    
    cell.imageView.image = [UIImage imageNamed:@"OID.png"];
    return cell;
}

-(CommonNavigationItem*)submenuNavigationItemForIndex:(NSIndexPath*)indexPath
{
    return nil;
}

- (UIViewController<NavigationSource>*)getDetailControllerForElementAt:(NSIndexPath*)index
{
    CertUsage *resultingUsage = (CertUsage*)(self.filtered ? [filteredUsages objectAtIndex:index.row] : [usageHelper.certUsages objectAtIndex:index.row]);
    return [[[CertUsageViewController alloc] initWithUsage:[[resultingUsage copy] autorelease] idLabel:nil descriptionLabel:nil] autorelease];
}

- (CGFloat)cellHeight:(NSIndexPath *)indexPath
{
    return 64;
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

- (BOOL)filterable
{
    return YES;
}

- (NSArray*)dataScopes
{
    if( !scopesArray )
    {
        scopesArray = [NSArray arrayWithObjects:NSLocalizedString(@"CERT_USAGE_IDENTIFICATOR", @"Идентификатор"), NSLocalizedString(@"CERT_USAGE_PURPOSE", @"Назначение"), nil];
    }
    return scopesArray;
}

- (void)applyFilterForSeachText:(NSString*)searchString andScope:(NSInteger)searchScope
{
    [filteredUsages removeAllObjects];
    
    for (CertUsage *usage in usageHelper.certUsages)
    {
        NSRange foundRange;
        switch (searchScope) {
            case 0: //by OID
                foundRange = [usage.usageId rangeOfString:searchString];
                break;
                
            case 1: //by Description
                foundRange = [usage.usageDescription rangeOfString:searchString];
                break;
                
            default:
                foundRange.location = NSNotFound;
                break;
        };
        
        if( foundRange.location != NSNotFound )
        {
            [filteredUsages addObject:usage];
        }
    }
}

@end
