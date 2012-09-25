//
//  ProfileViewController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"

#import "ProfileMenuModel.h"

@implementation ProfileViewController

@synthesize internalProfile;
@synthesize designationTable;
@synthesize parametersTable;

- (id)initWithProfile:(Profile*)profileForInit
{
    self = [super init];
    if (self) {
        Profile *initProfileCopy = [profileForInit copy];
        self.internalProfile = initProfileCopy;
        [initProfileCopy release];

        
        nameEditField = nil;
        descriptionEditField = nil;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)setEditMode:(BOOL)editModeValue
{
    editModeInternal = editModeValue;
    
    if( editModeInternal )
    {
        buttonsBar.view.hidden = FALSE;
        [UIView animateWithDuration:0.3 animations:^{
            buttonsBar.view.alpha = 1;
        }];
        
        if( !nameEditField )
        {
            nameEditField = [[UITextField alloc] init];
            nameEditField.borderStyle = UITextBorderStyleRoundedRect;
            nameEditField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            nameEditField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
        
        if( !descriptionEditField )
        {
            descriptionEditField = [[UITextField alloc] init];
            descriptionEditField.borderStyle = UITextBorderStyleRoundedRect;
            descriptionEditField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            descriptionEditField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
    }
    else
    {
        if( nameEditField )
        {
            [nameEditField removeFromSuperview];
        }
        
        if( descriptionEditField )
        {
            [descriptionEditField removeFromSuperview];
        }
    }
    
    designationTable.userInteractionEnabled = editModeInternal;
    [designationTable reloadData];
}

- (BOOL)editMode
{
    return editModeInternal;
}

- (void)dealloc
{
    [designationTable release];
    [parametersTable release];
    [internalProfile release];
    [nameEditField release];
    [descriptionEditField release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    designationTable.dataSource = self;
    
    parametersTable.dataSource = self;
    parametersTable.delegate = self;
    
    designationTable.backgroundView = [[[UIView alloc] initWithFrame:designationTable.bounds] autorelease];
    parametersTable.backgroundView = [[[UIView alloc] initWithFrame:parametersTable.bounds] autorelease];
    
    designationTable.userInteractionEnabled = self.editMode;
    
    
    buttonsBar = [[SaveDelButtonsPanelController alloc] initWithSaveAction:@selector(saveAction) andDelAction:@selector(deleteAction) forObject:self];
    buttonsBar.view.hidden = TRUE;
    buttonsBar.view.alpha = 0;
    buttonsBar.view.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44);
    [self.view addSubview:buttonsBar.view];
    
    self.editMode = self.editMode;
}

- (void)viewDidUnload
{
    [self setDesignationTable:nil];
    [self setParametersTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - NavigationSource protocol support

+ (NSString*)itemTag
{
    return @"ProfileViewController";
}

- (NSString*)itemTag
{
    return [ProfileViewController itemTag];
}

- (NSString*)title
{
    return NSLocalizedString(@"PROFILE_TITLE", @"Операционная настройка");
}

- (NSArray*)getAdditionalButtons
{
    return [NSArray arrayWithObject:[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Edit.png"] style:UIBarButtonItemStylePlain target:self action:@selector(editAction)] autorelease]];
}

//- (void)setParentNavigationController:(UIViewController*)navController
//{
//
//}

- (BOOL)preserveController
{
    return FALSE;
}

- (SettingsMenuSource*)settingsMenu
{
    return nil;
}

- (Class)getSavingObjcetClass
{
    return [ProfileMenuModel class];
}

- (id<MenuDataRefreshinProtocol>)createSavingObject
{
    return [[[ProfileMenuModel alloc] init] autorelease];
}

//- (void)dismissPopovers
//{
//    
//}

#pragma mark - Table view data source and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (tableView == designationTable ? 2 : 4);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell";
    if(tableView == designationTable && self.editMode)
    {
        CellIdentifier = @"Cell-namedescr";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if( tableView == designationTable )
    {
        if( !self.editMode )
        {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = self.internalProfile.name;
                    break;
                    
                case 1:
                    cell.textLabel.text = self.internalProfile.description;
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            cell.textLabel.text = @" ";
            switch (indexPath.row) {
                case 0:
                {
                    nameEditField.frame = cell.textLabel.bounds;
                    nameEditField.text = self.internalProfile.name;
                    [cell.textLabel addSubview:nameEditField];
                    cell.textLabel.autoresizesSubviews = YES;
                    cell.textLabel.userInteractionEnabled = YES;
                }
                    break;
                    
                case 1:
                {
                    descriptionEditField.frame = cell.textLabel.bounds;
                    descriptionEditField.text = self.internalProfile.description;
                    [cell.textLabel addSubview:descriptionEditField];
                    cell.textLabel.autoresizesSubviews = YES;
                    cell.textLabel.userInteractionEnabled = YES;
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    else if( tableView == parametersTable )
    {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"PROILE_SIGNING", @"Подпись");
                break;
                
            case 1:
                cell.textLabel.text = NSLocalizedString(@"PROILE_ENCRYPTION", @"Шифрование");
                break;
                
            case 2:
                cell.textLabel.text = NSLocalizedString(@"PROILE_DECRYPTION", @"Расшифрование");
                break;
                
            case 3:
                cell.textLabel.text = NSLocalizedString(@"PROILE_CERT_POLICY", @"Политика сертификатов");
                break;
                
            default:
                break;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if( tableView == parametersTable )
    {
        return NSLocalizedString(@"PROILE_PARAMETERS", @"Параметры настройки");
    }
    
    return NSLocalizedString(@"PROILE_NAME", @"Наименование настройки");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //ParametersPanel *parametersPanel = [[ParametersPanel alloc] initWithParentPage:self];
    ParametersPanel *parametersPanel = [[ParametersPanel alloc] initWithParentProfile:self.internalProfile];
    
    switch (indexPath.row) {
        case 0:
            parametersPanel.panelTypeId = PT_SIGNING;
            parametersPanel.title = NSLocalizedString(@"PROILE_SIGNING", @"Подпись");
            break;
            
        case 1:
            parametersPanel.panelTypeId = PT_ENCRYPTION;
            parametersPanel.title = NSLocalizedString(@"PROILE_ENCRYPTION", @"Шифрование");
            break;
            
        case 2:
            parametersPanel.panelTypeId = PT_DECRYPTION;
            parametersPanel.title = NSLocalizedString(@"PROILE_DECRYPTION", @"Расшифрование");
            break;
            
        case 3:
            parametersPanel.panelTypeId = PT_CERTPOLICY;
            parametersPanel.title = NSLocalizedString(@"PROILE_CERT_POLICY", @"Политика сертификатов");
            break;
            
        default:
            break;
    }
    
    parametersPanel.editMode = self.editMode;
    parametersPanel.parentNavigationController = parentNavController;
    [parentNavController pushNavController:parametersPanel];
    [parametersPanel refreshTableData];
    //parametersPanel.view.userInteractionEnabled = self.editMode;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [parametersPanel release];
}

#pragma mark - Actions

- (void)editAction
{
    self.editMode = YES;
}

- (BOOL)saveAction
{
    if( !nameEditField.text.length )
    {
        return FALSE;
    }
    
    internalProfile.name = nameEditField.text;
    internalProfile.description = descriptionEditField.text;
    
    self.editMode = NO;
    
    ProfileMenuModel *savingObject = [self getSavingObject];
    [savingObject saveExistingElement:self.internalProfile];
    
    [designationTable reloadData];
    [parentNavController refreshMenuData];
    
    return YES;
}

- (BOOL)deleteAction
{
    self.editMode = NO;
    
    ProfileMenuModel *savingObject = [self getSavingObject];
    [savingObject removeElement:self.internalProfile];
    
    [parentNavController refreshMenuData];
    [parentNavController.navCtrlr popViewControllerAnimated:YES];
    
    return YES;
}

@end
