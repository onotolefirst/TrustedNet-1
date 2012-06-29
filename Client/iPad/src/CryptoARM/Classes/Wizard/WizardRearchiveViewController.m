//
//  WizardRearchiveViewController.m
//  CryptoARM
//
//  Created by Денис Бурдин on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WizardRearchiveViewController.h"

@implementation WizardRearchiveViewController
@synthesize tblRecipients, isShowingLandscapeView, tableContent, currentTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withFolderPath:(NSString*)strFolder
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // show all content in tmp folder
        tableContent = [[NSMutableArray alloc] init];

        if (strFolder)
        {
            if ([[strFolder componentsSeparatedByString:@"."] count] < 2)
            {
                // this is directory
                NSError *error;
                NSArray *dirContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:strFolder error:&error];
                
                if (dirContent)
                {
                    // show all dirContent items as cell items
                    for (int  i = 0; i < [dirContent count]; i++)
                    {
                        ArchiveMenuModelObject *someFile = [[ArchiveMenuModelObject alloc] initWithFilePath:[strFolder stringByAppendingPathComponent:[dirContent objectAtIndex:i]]];
                        [tableContent addObject:someFile];
                    }
                }
                else
                {
                    // TODO: throw error: file path not found
                }
            }
        }
        else
        {
            NSString *strTmpPath = [NSString stringWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
            strTmpPath = [strTmpPath stringByDeletingLastPathComponent];
            strTmpPath = [strTmpPath stringByAppendingPathComponent:@"tmp"];
        
            NSFileManager *localFileManager = [[NSFileManager alloc] init];
            NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:strTmpPath];
            NSArray *arrEntireTreeView = [[NSArray alloc] initWithArray:[dirEnum allObjects]];
        
            NSString *strPath;
            NSString *strRootComponent;
            NSMutableArray *arrRootComponents = [[NSMutableArray alloc] init];
            for (strPath in arrEntireTreeView)
            {
                NSArray *arrAllComponents = [strPath componentsSeparatedByString:@"/"];
                NSString *strRootComponent = [arrAllComponents objectAtIndex:0];
            
                if (![arrRootComponents containsObject:strRootComponent])
                {
                    [arrRootComponents addObject:strRootComponent];
                }
            }

            for(strRootComponent in arrRootComponents)
            {
                ArchiveMenuModelObject *zipFile = [[ArchiveMenuModelObject alloc] initWithFilePath:[strTmpPath stringByAppendingPathComponent:strRootComponent]];
                [tableContent addObject:zipFile];
            }
        }
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        
    tblRecipients.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tblRecipients.dataSource = self;
    tblRecipients.delegate = self;
    [tblRecipients reloadData];
        
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f) ];
    toolbar.barStyle = UIBarStyleDefault;
     
    // create the array to hold the buttons, which then gets added to the toolbar
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    // create a standard "cancel" button
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(buttonCancel:)];
    cancelButton.style = UIBarButtonItemStyleBordered;
    [cancelButton setTitle:(NSLocalizedString(@"CANCEL", @"CANCEL"))];
    [buttons addObject:cancelButton];
    [cancelButton release];
    
    // create a spacer
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [buttons addObject:spacer];
    [spacer release];
    
    // create a standard "add" button
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(buttonAdd:)];
    [addButton setTitle:NSLocalizedString(@"ADD", @"ADD")];
    addButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:addButton];
    [addButton release];
    
    // stick the buttons in the toolbar
    [toolbar setItems:buttons animated:NO];    
    [buttons release];
        
    [self.view addSubview:toolbar];
    [toolbar release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
    {
        isShowingLandscapeView = YES;
        [tblRecipients reloadData];
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
    {
        isShowingLandscapeView = NO;
        [tblRecipients reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - NavigationSource protocol support

+ (NSString*)itemTag
{
    return @"WizardRearchiveViewController";
}

- (NSString*)itemTag
{
    return [WizardRearchiveViewController itemTag];
}

- (NSString*)title
{
    return NSLocalizedString(@"WIZARD_REARCHIVE_MANAGER_TITLE", @"WIZARD_REARCHIVE_MANAGER_TITLE");
}

- (NSArray*)getAdditionalButtons
{
    return nil;
}

- (void)setParentNavigationController:(UIViewController*)navController
{
    parentController = (DetailNavController*)navController;
}

- (BOOL)preserveController
{
    return FALSE;
}

- (SettingsMenuSource*)settingsMenu
{
    return settingsMenu;
}

- (void)constructSettingsMenu
{
    if( settingsMenu )
    {
        [settingsMenu release];
    }
    
    settingsMenu = [[SettingsMenuSource alloc] initWithTitle:NSLocalizedString(@"WIZARD_DOCUMENT_OPERATION", @"WIZARD_DOCUMENT_OPERATION")];
}

- (Class)getSavingObjcetClass
{
    //TODO: implement, if necessary
    return [self class];
}

- (id<MenuDataRefreshinProtocol>)createSavingObject
{
    //TODO: implement, if necessary
    return nil;
}

- (void)dealloc
{
    [tableContent release];
    
    [super dealloc];
}

#pragma mark - toolbar action(add|cancel)
- (void)buttonCancel:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WARNING", @"WARNING") message:@"Cancel" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    [alert release];        

}

- (void)buttonAdd:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WARNING", @"WARNING") message:@"Add" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    [alert release];        
    
}

#pragma mark table view controller delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // return number of records in the address book
    return [tableContent count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSArray *nib;
    NSString *CellIdentifier;
    
    if (isShowingLandscapeView)
    {
        nib = [[NSBundle mainBundle] loadNibNamed:@"FileItemCellViewLandscape" owner:self options:nil];
        CellIdentifier = [NSString stringWithFormat:@"FileItemCellViewLandscape %d %d", indexPath.section, indexPath.row];
    }
    else
    {
        nib = [[NSBundle mainBundle] loadNibNamed:@"FileItemCellViewPortrait" owner:self options:nil];
        CellIdentifier = [NSString stringWithFormat:@"FileItemCellViewPortrait %d %d", indexPath.section, indexPath.row];
    }
    
    FileItemCellView *cell = (FileItemCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        currentTableView = tableView;
        cell = (FileItemCellView *)[nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        ArchiveMenuModelObject *cellObject = (ArchiveMenuModelObject *)[tableContent objectAtIndex:indexPath.row];
        
        if (cellObject)
        {
            if (cellObject.title)
            {
                [cell.title setText:cellObject.title];
            }
            
            if (cellObject.creationDate)
            {
                [cell.creationDate setText:cellObject.creationDate];
            }
            
            if (cellObject.size)
            {
                [cell.size setText:cellObject.size];
            }
            
            if (cellObject.typeOrContent)
            {
                [cell.typeOrContent setText:cellObject.typeOrContent];
            }
            
            if (cellObject.fullFilePath)
            {
                cell.fullFilePath = [cellObject.fullFilePath copy];
                
                if ([[[cellObject.fullFilePath lastPathComponent] componentsSeparatedByString:@"."] count] < 2)
                {
                    // this is folder
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
            
            // set image by its file extension
            [cell.docImageView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:cellObject.strDocImagePath] waitUntilDone:YES];
            
            // initialize btnTick with action and image
            UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(6, 15, 25, 25)] autorelease];
                        
            BOOL isSelected = NO;            
            if (isSelected)
            {
                cell.checked = YES;
                [imgView setImage:[UIImage imageNamed:@"checked.PNG"]];
            }
            else
            {
                cell.checked = NO;
                [imgView setImage:[UIImage imageNamed:@"unchecked.PNG"]];
            }
            
            [cell.btnTick addSubview:imgView];
            [cell.btnTick addTarget:self action:@selector(setCellItemSelected:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnTick setTitle:[NSString stringWithFormat:@"%d", indexPath.row] forState:UIControlStateNormal];
        }
        else
        {
            return nil;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileItemCellView *cell = (FileItemCellView *)[tableView cellForRowAtIndexPath:indexPath];

    // determine type of the document by its extension
    if (cell.fullFilePath && ([cell.fullFilePath length] != 0))
    {
        NSArray *arrExtensions = [[cell.fullFilePath lastPathComponent] componentsSeparatedByString:@"."];
        
        if ([arrExtensions count] < 2)
        {
            // it is a folder
            [parentController pushNavController:[[WizardRearchiveViewController alloc] initWithNibName:@"WizardRearchiveViewController" bundle:nil withFolderPath:cell.fullFilePath]];
        }
    }
}

- (void)setCellItemSelected:(id)sender
{
    UIButton *btnSelectCell = (UIButton *)sender;
    UIImageView *imgTickView = (UIImageView *)[[btnSelectCell subviews] objectAtIndex:1];
    FileItemCellView *cell = (FileItemCellView *)[currentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[btnSelectCell.titleLabel.text integerValue] inSection:0]];
        
    if (cell.checked)
    {
        cell.checked = NO;
        [imgTickView setImage:[UIImage imageNamed:@"unchecked.PNG"]];
    }
    else
    {
        cell.checked = YES;
        [imgTickView setImage:[UIImage imageNamed:@"checked.PNG"]];
    }
}

@end
