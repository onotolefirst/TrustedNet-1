 //
//  SelectAlgorithm.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectAlgorithm.h"

#import "Crypto.h"

@implementation SelectAlgorithm

@synthesize parentProfile;
@synthesize pageType;

@synthesize algList;

- (id)initWithParentProfile:(Profile*)profileFromParent andPageType:(enum ALG_PAGE_TYPE)newPageType;
{
    self = [super init];
    if (self)
    {
        pageType = newPageType;
        self.parentProfile = profileFromParent;
        
        switch (self.pageType) {
            case APT_SIGN_HASH:
                //TODO: check certificate key type to request appropriate algorithm list
                self.algList = [Crypto getDigestAlgorithmList];
                break;
                
//            case APT_ENCRYPR_ALG:
//                self.algList = [Crypto getCiphersAlgorithmList];
//                break;
                
            default:
                break;
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

- (UITableView*)tableView
{
    return (UITableView*)self.view;
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UITableView *mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStyleGrouped];
    self.view = mainTableView;
    [mainTableView release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.algList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectOidViewController Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...

    NSNumber *nid = [self.algList objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%s", OBJ_nid2ln(nid.intValue)];
    
    if( self.parentProfile.signHashAlgorithm && ([self.parentProfile.signHashAlgorithm compare:[Crypto convertAsnObjectToString:OBJ_nid2obj(nid.intValue) noName:YES]] == NSOrderedSame) )
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */

    NSNumber *nid = [self.algList objectAtIndex:indexPath.row];
    self.parentProfile.signHashAlgorithm = [Crypto convertAsnObjectToString:OBJ_nid2obj(nid.intValue) noName:YES];
    
    [parentNavController.navCtrlr popViewControllerAnimated:YES];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"PROFILE_SEL_ALG_SIGNATURE_HASH_ALG_TYPE", @"Тип хэш-алгоритма подписи");
}

#pragma mark - NavigationSource protocol support

+ (NSString*)itemTag
{
    return @"SelectAlgorithmViewController";
}

- (NSString*)itemTag
{
    return [SelectAlgorithm itemTag];
}

- (NSString*)title
{
    switch (self.pageType) {
        case APT_SIGN_HASH:
            return NSLocalizedString(@"PROFILE_SEL_ALG_HASH_ALG_TYPE", @"Тип хэш-алгоритма");
            break;
            
//        case APT_ENCRYPR_ALG:
//            return @"Тип алгоритма";
//            break;

        default:
            break;
    }
    return NSLocalizedString(@"PROFILE_SEL_ALG_SELECT_ALGOTITHM", @"Выберите алгоритм");
}

- (SettingsMenuSource*)settingsMenu
{ 
    return nil;
}

- (void)constructSettingsMenu
{
}

- (NSArray*)getAdditionalButtons
{
    return [NSArray arrayWithObject:[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BUTTON_DONE", @"Готово") style:UIBarButtonItemStyleBordered target:self action:@selector(actionForDoneButton)] autorelease]];
}

- (void)setParentNavigationController:(UIViewController*)navController
{
    parentNavController = (DetailNavController*)navController;
}

- (BOOL)preserveController
{
    return FALSE;
}

- (Class)getSavingObjcetClass
{
    return [self class];
}

- (id<MenuDataRefreshinProtocol>)createSavingObject
{
    return nil;
}

@end
