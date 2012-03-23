//
//  MainMenuModel.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenuModel.h"

#import "CertMenuModel.h"
#import "ProfileMenuModel.h"
#import "CertificateUsageMenuModel.h"


@implementation MainMenuModel

@synthesize selectedRowIndex;


- (id)init
{
    self = [super init];
    self.selectedRowIndex = nil;
    
    return self;
}

- (NSString*)menuTitle
{
    return NSLocalizedString(@"SECTIONS", @"Разделы");
}

- (NSInteger)mainMenuSections
{
    return 1;
}

- (NSInteger)mainMenuRowsInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCellAccessoryType)typeOfElementAt:(NSIndexPath*)idx
{
    return UITableViewCellAccessoryDisclosureIndicator;
}

- (UITableViewCell*)fillCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)idx inTableView:(UITableView*)tableView
{    
    cell.accessoryType = [self typeOfElementAt:idx];
    cell.imageView.image = [UIImage imageNamed:@"folder.png"];
    cell.textLabel.adjustsFontSizeToFitWidth = TRUE;
    cell.textLabel.font = [cell.textLabel.font fontWithSize:14];
    
    if( self.selectedRowIndex && self.selectedRowIndex.row == idx.row )
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    switch (idx.row) {
        case 0:
        {
            cell.textLabel.text = NSLocalizedString(@"MM_PRIVATE_CERTIFICATES", @"MM_PRIVATE_CERTIFICATES");
        }
            break;

        case 1:
        {
            cell.textLabel.text =  NSLocalizedString(@"MM_OTHER_PEOPLE_CERTIFICATES", @"MM_OTHER_PEOPLE_CERTIFICATES");
        }
            break;
            
        case 2:
        {
            cell.textLabel.text = NSLocalizedString(@"MM_INTERMEDAITE_CERTIFICATION_AUTHORITIES", @"MM_INTERMEDAITE_CERTIFICATION_AUTHORITIES");
        }
            break;
            
        case 3:
        {
            cell.textLabel.text = NSLocalizedString(@"MM_TRUSTED_ROOT_CERTIFICATION_AUTHORITIES", @"MM_TRUSTED_ROOT_CERTIFICATION_AUTHORITIES");
        }
            break;
            
        case 4:
        {
            cell.textLabel.text = NSLocalizedString(@"MM_CERTIFICATE_REVOCATION_LIST", @"MM_CERTIFICATE_REVOCATION_LIST");
        }
            break;
            
        case 5:
        {
            cell.textLabel.text = NSLocalizedString(@"MM_CERTIFICATE_ENROLLMENT_REQUESTS", @"MM_CERTIFICATE_ENROLLMENT_REQUESTS");
        }
            break;
            
        case 6:
        {
            cell.textLabel.text = NSLocalizedString(@"MM_OPERATIONAL_SETTINGS", @"MM_OPERATIONAL_SETTINGS");
        }
            break;
            
        case 7:
        {
            cell.textLabel.text = NSLocalizedString(@"MM_CERTIFICATE_PURPOSE_REFERENCE", @"MM_CERTIFICATE_PURPOSE_REFERENCE");
        }
            break;
            
        case 8:
        {
            cell.textLabel.text = NSLocalizedString(@"MM_CERTIFICATE_PRINT_TEMPLATES", @"MM_CERTIFICATE_PRINT_TEMPLATES");
        }
            break;
            
        default:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"Section %d, Row %d", idx.section+1, idx.row+1];
        }
            break;
    }
    
    return cell;
}

- (CommonNavigationItem*)submenuNavigationItemForIndex:(NSIndexPath*)indexPath
{
    self.selectedRowIndex = indexPath;
    
    switch (indexPath.row)
    {
        case 0:
            return [[[CertMenuModel alloc] initWithStoreName:@"My"] autorelease];
            break;
            
        case 1:
            return [[[CertMenuModel alloc] initWithStoreName:@"AddressBook"] autorelease];
            break;
            
        case 2:
            return [[[CertMenuModel alloc] initWithStoreName:@"CA"] autorelease];
            break;
            
        case 3:
            return [[[CertMenuModel alloc] initWithStoreName:@"Root"] autorelease];
            break;            
            
        case 6:
            return [[[ProfileMenuModel alloc] init] autorelease];
            break;
            
        case 7:
            return [[[CertificateUsageMenuModel alloc] init] autorelease];
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (UIViewController<NavigationSource>*)getDetailControllerForElementAt:(NSIndexPath*)index
{
    return nil;
}

- (void)dealloc
{
    [selectedRowIndex release];
    
    [super dealloc];
}

@end
