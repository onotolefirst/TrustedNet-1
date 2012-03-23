//
//  ProfileViewController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParametersPanel.h"
#import "SaveDelButtonsPanelController.h"


@interface ProfileViewController : CommonDetailController <NavigationSource, UITableViewDataSource, UITableViewDelegate>
{
    BOOL editModeInternal;
    SaveDelButtonsPanelController *buttonsBar;
    
    UITextField *nameEditField;
    UITextField *descriptionEditField;
}

@property (nonatomic, retain) Profile *internalProfile;

@property (retain, nonatomic) IBOutlet UITableView *designationTable;
@property (retain, nonatomic) IBOutlet UITableView *parametersTable;

@property BOOL editMode;

- (id)initWithProfile:(Profile*)profileForInit;

- (void)editAction;
- (BOOL)saveAction;
- (BOOL)deleteAction;

@end
