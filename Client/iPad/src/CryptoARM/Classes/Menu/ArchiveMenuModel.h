//
//  ArchiveMenuModel.h
//  CryptoARM
//
//  Created by Денис Бурдин on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZipArchive.h"
#import "ArchiveMenuModelContent.h"
#import "ArchiveMenuModelObject.h"
#import "CommonNavigationItem.h"
#import "NavigationSource.h"
#import "MenuNavigationDelegate.h"
#import "WizardRearchiveViewController.h"

@interface ArchiveMenuModel : CommonNavigationItem
{
    ZipArchive *archive;
    NSMutableArray *tableContent;
    NSString *strFilename;
    UITableView *currentTableView;
    UINavigationController *parentNavigationController;
    NSMutableDictionary *dicEntireTreeView; // general item, placed in the root ArchiveMenuModel table view controller
    bool isSubmenu; // designates whether open submenu(true) or should rebuild menu table view(false)
    BOOL bZipped;
    id<MenuNavigationDelegate> navigationDelegate;
    BOOL root;
    NSArray *selectedItems;
}

@property (nonatomic, retain) ZipArchive *archive;
@property (nonatomic, retain) NSArray *selectedItems;
@property (nonatomic, retain) UINavigationController *parentNavigationController;
@property (nonatomic, retain) NSMutableArray *tableContent;
@property (nonatomic, retain) NSString *strFilename;
@property (nonatomic, retain) UITableView *currentTableView;
@property (nonatomic, retain) NSMutableDictionary *dicEntireTreeView;
@property (nonatomic, assign) bool isSubmenu;
@property (nonatomic, assign) BOOL bZipped;
@property (nonatomic, assign) BOOL root;
@property (nonatomic, retain) id<MenuNavigationDelegate> navigationDelegate;

// isRoot flag indicates the first calling of this function to build entre directory tree view inside an archive
// it is intended for storing information about selected ArchiveMenuModelContent cell view items to transfer number
// of selected items in the root ArchiveMenuModel tableView stack of view controllers
- (id)initWithFilePath:(NSString *)strPath isArchive:(BOOL)bArchive isRoot:(BOOL)bRoot parentNavController:(UINavigationController *)navController;

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)showConfirmOpenZipAlert;
- (void)showConfirmUnzipAllAlert;
- (void)setCellItemSelected:(id)sender;
- (void)reloadTableWithNewItem:(NSString*)strItemPath;

@end
