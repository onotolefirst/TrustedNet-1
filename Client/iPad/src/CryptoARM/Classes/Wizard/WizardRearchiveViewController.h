//
//  WizardRearchiveViewController.h
//  CryptoARM
//
//  Created by Денис Бурдин on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailNavController.h"
#import "ArchiveMenuModelObject.h"
#import "FileItemCellView.h"

@interface WizardRearchiveViewController : UIViewController<NavigationSource,UITableViewDataSource,UITableViewDelegate>
{
    SettingsMenuSource *settingsMenu;
    DetailNavController *parentController;
    UITableView *tblRecipients;
    bool isShowingLandscapeView;
    NSMutableArray *tableContent;
    UITableView *currentTableView;
}

- (void)buttonCancel:(id)sender;
- (void)buttonAdd:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withFolderPath:(NSString*)strFolder;

@property (nonatomic, retain) IBOutlet UITableView *tblRecipients;
@property (nonatomic, assign) bool isShowingLandscapeView;
@property (nonatomic, retain) NSMutableArray *tableContent;
@property (nonatomic, retain) UITableView *currentTableView;

@end
