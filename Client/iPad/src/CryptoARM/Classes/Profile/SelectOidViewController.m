//
//  SelectOidViewController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectOidViewController.h"
#import "PathHelper.h"

@implementation SelectOidViewController

@synthesize parentProfile;
@synthesize pageType;

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (UIImage*)constructImageWithStatus:(UIImage*)statusImage andCheckButton:(UIImage*)checkButton
{
    UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 80)];
    
    UIImageView *checkView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 28, 25, 24)];
    checkView.image = checkButton;
    UIImageView *statusView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, 80, 80)];
    statusView.image = statusImage;
    
    [imageView addSubview:statusView];
    [imageView addSubview:checkView];
    
    UIGraphicsBeginImageContext(imageView.bounds.size);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [imageView release];
    [checkView release];
    [statusView release];
    
    return [resultImage retain];
}

- (id)initWithProfile:(id)profile andPageType:(enum OID_SELECT_PAGE_TYPE)pgType
{
    self = [super init];
    if (self)
    {
        self.parentProfile = profile;
        
        NSString *savingFileName = [[NSString stringWithFormat:@"%@/%@", [PathHelper getOperationalSettinsDirectoryPath], [PathHelper getCertUsagesFileName]] copy];
        
        usagesHelper = [[CertUsageHelper alloc] initWithDictionary:savingFileName];
        [savingFileName release];
        
        selectedIndex = [[NSMutableIndexSet alloc] init];
        
        pageType = pgType;
        NSArray *loadingFilter;
        switch (self.pageType) {
            case OSPT_SIGN_FILTER:
                loadingFilter = self.parentProfile.signCertFilter;
                break;
                
            case OSPT_ENCRYPT_FILTER:
                loadingFilter = self.parentProfile.encryptCertFilter;
                break;
                
            default:
                break;
        }
        
        for (CertUsage *currentProfileUsageItem in loadingFilter) {
            for (CertUsage *currentStoreUsageItem in usagesHelper.certUsages) {
                NSUInteger currentStoreIndex = [usagesHelper.certUsages indexOfObject:currentStoreUsageItem];
                
                if( [selectedIndex containsIndex:currentStoreIndex] )
                {
                    continue;
                }
                
                if( [currentStoreUsageItem.usageId compare:currentProfileUsageItem.usageId] == NSOrderedSame )
                {
                    [selectedIndex addIndex:currentStoreIndex];
                    break;
                }
            }
        }
        
        checkedOid = [self constructImageWithStatus:[UIImage imageNamed:@"OID.png"] andCheckButton:[UIImage imageNamed:@"checked.PNG"]];
        uncheckedOid = [self constructImageWithStatus:[UIImage imageNamed:@"OID.png"] andCheckButton:[UIImage imageNamed:@"unchecked.PNG"]];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [usagesHelper release];
    [checkedOid release];
    [uncheckedOid release];
    [selectedIndex release];
    
    [super dealloc];
}

- (UITableView*)tableView
{
    return (UITableView*)self.view;
}

#pragma mark - View lifecycle

- (void)loadView
{
    UITableView *mainTableView = [[UITableView alloc] init];
    self.view = mainTableView;
    [mainTableView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    return usagesHelper.certUsages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectOidViewController Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    CertUsage *currentUsage = [usagesHelper.certUsages objectAtIndex:indexPath.row];
    cell.textLabel.text = currentUsage.usageId;
    cell.detailTextLabel.text = currentUsage.usageDescription;
    
    if( [selectedIndex containsIndex:indexPath.row] )
    {
        cell.imageView.image = checkedOid;
    }
    else
    {
        cell.imageView.image = uncheckedOid;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
    
    if( [selectedIndex containsIndex:indexPath.row] )
    {
        [selectedIndex removeIndex:indexPath.row];
    }
    else
    {
        [selectedIndex addIndex:indexPath.row];
    }
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - NavigationSource protocol support

+ (NSString*)itemTag
{
    return @"SelectOidViewController";
}

- (NSString*)itemTag
{
    return [SelectOidViewController itemTag];
}

- (NSString*)title
{
    return NSLocalizedString(@"CERT_USAGE_CERTIFICATE_USAGES", @"Назначения сертификата");
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

#pragma mark - Controls actions

- (void)actionForDoneButton
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:selectedIndex.count]; //+ count of other indexes
    
    [selectedIndex enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        CertUsage *certUsage = [usagesHelper.certUsages objectAtIndex:idx];
        [resultArray addObject:certUsage];
    }];
    
    switch (self.pageType) {
        case OSPT_SIGN_FILTER:
            self.parentProfile.signCertFilter = resultArray;
            break;
            
        case OSPT_ENCRYPT_FILTER:
            self.parentProfile.encryptCertFilter = resultArray;
            break;
            
        default:
            break;
    }
    
    [resultArray release];
    
    [parentNavController.navCtrlr popViewControllerAnimated:YES];
}

@end
