#import "SystemSettingsMenuViewController.h"

@implementation SystemSettingsMenuViewController
@synthesize menuTable, menuItemsArray, settingsMenuPopover;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    menuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44) style:UITableViewStylePlain];
    
    menuTable.delegate = self;
    menuTable.dataSource = self;
    
    menuTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [menuTable reloadData];
    self.view = menuTable;

    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    [self setMenuTable:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (CGFloat)calculateMenuHeight
{
    return 60 * ([menuTable numberOfRowsInSection:0]) + 35;
}

- (void)dealloc
{
    [menuItemsArray release];
    [menuTable release];
    
    if (settingsMenuPopover)
    {
        [settingsMenuPopover dismissPopoverAnimated:YES];
    }
    
    [super dealloc];
}

- (void)addMenuItem:(NSString*)itemTitle andCreationDate:(NSString *)strCreationDate andOwner:(NSString *)strOwner
{
    if (!menuItemsArray)
    {
        menuItemsArray = [[NSMutableArray alloc] init];
    }
    
    SystemSettingsMenuCellContent *item = [[SystemSettingsMenuCellContent alloc] initWithTitle:itemTitle andCreationDate:(NSString *)strCreationDate andOwner:(NSString *)strOwner];
    [menuItemsArray addObject:item];
    [item release];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [menuItemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"System settings menu cell %d %d", indexPath.section, indexPath.row];
    
    SystemSettingsMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SystemSettingsMenuCell" owner:self options:nil];
        cell = (SystemSettingsMenuCell *)[nib objectAtIndex:0];

        SystemSettingsMenuCellContent *cellContent = (SystemSettingsMenuCellContent *)[menuItemsArray objectAtIndex:indexPath.row];
        
        // init cell from array
        [cell.title setText:cellContent.title];
        [cell.owner setText:cellContent.owner];
        [cell.creationDate setText:cellContent.creationDate];

        // set image
        cell.imgSettings.image = [UIImage imageNamed:@"profile.png"];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [settingsMenuPopover dismissPopoverAnimated:YES];
}

- (void)setPopoverController:(UIPopoverController *)controller
{
    settingsMenuPopover = controller;
}

@end
