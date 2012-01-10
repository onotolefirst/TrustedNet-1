//
//  MainMenuModel.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenuModel.h"

#import "CertMenuModel.h"
#import "CertificateUsageMenuModel.h"


@implementation MainMenuModel

@synthesize selectedRowIndex;


- (id)init
{
    self = [super init];
    
    self.title = @"Разделы";
    self.selectedRowIndex = nil;
    
    return self;
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
            cell.textLabel.text = NSLocalizedString(@"MM_PRIVATE_CERTIFICATES", @"Private certificates");
        }
            break;

        case 1:
        {
            cell.textLabel.text = @"Сертификаты других пользователей";
        }
            break;
            
        case 2:
        {
            cell.textLabel.text = @"Сертификаты промежуточных центров";
        }
            break;
            
        case 3:
        {
            cell.textLabel.text = @"Доверенные корневые центры";
        }
            break;
            
        case 4:
        {
            cell.textLabel.text = @"Списки отзыва сертификатов";
        }
            break;
            
        case 5:
        {
            cell.textLabel.text = @"Запросы на сертификат";
        }
            break;
            
        case 6:
        {
            cell.textLabel.text = @"Операционные настройки";
        }
            break;
            
        case 7:
        {
            cell.textLabel.text = @"Справочник назначений сертификата";
        }
            break;
            
        case 8:
        {
            cell.textLabel.text = @"Шаблоны печати сертификата";
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
    
    switch (indexPath.row) {
        case 0:
        {
            return [[[CertMenuModel alloc] init] autorelease];
        }
            break;
            
        case 7:
        {
            return [[[CertificateUsageMenuModel alloc] init] autorelease];
        }
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
