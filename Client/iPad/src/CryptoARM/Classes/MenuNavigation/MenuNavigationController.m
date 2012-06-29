//
//  MenuNavigationController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuNavigationController.h"

#import "MainMenuModel.h"
#import "DetailNavController.h"
#import "MenuListController.h"

@implementation MenuNavigationController
@synthesize menuNavController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        menuNavController = [[UINavigationController alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)reloadMenuData
{
    MenuListController *topViewController = (MenuListController*)[menuNavController topViewController];
    
    if( topViewController.menuModel.filtered )
    {
        //NSLog(@"%@", topViewController.searchDisplayController.searchBar.text);
        [topViewController.menuModel applyFilterForSeachText:topViewController.searchDisplayController.searchBar.text andScope:topViewController.searchDisplayController.searchBar.selectedScopeButtonIndex];
    }
    
    [topViewController.currentTableView reloadData];
}

- (CommonNavigationItem<MenuDataRefreshinProtocol>*)currentMenuItem
{
    MenuListController *currentController = (MenuListController*)menuNavController.topViewController;
    return (CommonNavigationItem<MenuDataRefreshinProtocol>*)currentController.menuModel;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    UINavigationBar *navBar = menuNavController.navigationBar;
    navBar.tintColor = [UIColor colorWithRed:(CGFloat)187/255 green:(CGFloat)2/255 blue:(CGFloat)4/255 alpha:1];
    menuNavController.view.frame = self.view.bounds;
    [self.view addSubview:menuNavController.view];
    
    MainMenuModel *rootItem = [[MainMenuModel alloc] init];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.action = @selector(returnToSection:);
    backButton.target = self;
    backButton.image = [UIImage imageNamed:@"to-section.PNG"];
    
    MenuListController *rootViewController = [[MenuListController alloc] initWithMenuItem:rootItem andSplitViewController:nil];
    rootViewController.navigationDelegate = self;
    
    [menuNavController pushViewController:rootViewController animated:NO];
    menuNavController.navigationBar.topItem.title = [rootItem menuTitle];
    menuNavController.navigationBar.topItem.leftBarButtonItem = backButton;
    
    MainSplitViewController *parentSplitViewController = (MainSplitViewController *)[self parentViewController];
    if (parentSplitViewController.archiveMenuModelController)
    {      
        // push menu subview controller(archive content table view)
        MenuListController *subViewController = [[MenuListController alloc] initWithMenuItem:parentSplitViewController.archiveMenuModelController andSplitViewController:parentSplitViewController];
        subViewController.navigationDelegate = self;
        
        [menuNavController pushViewController:subViewController animated:NO];
        menuNavController.navigationBar.topItem.title = NSLocalizedString(@"ROOT_FILES_FOR_PROCESSING", @"ROOT_FILES_FOR_PROCESSING");

        [subViewController release];
        [parentSplitViewController.archiveMenuModelController release];
    }

    [rootItem release];
    [backButton release];
    [rootViewController release];
    
    [self reloadMenuData];
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

- (void)dealloc {
    [menuNavController release];
    [super dealloc];
}

#pragma mark - menu navigation delegate protocol support
- (void)addItem:(CommonNavigationItem*)newItem forIndex:(NSIndexPath*)currentIndex
{
    UITableView *menuTable = ((UITableViewController*)menuNavController.topViewController).tableView;
    [menuTable deselectRowAtIndexPath:currentIndex animated:YES];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.action = @selector(back:);
    backButton.target = self;
    backButton.image = [UIImage imageNamed:@"to-root.PNG"];
    
    MenuListController *newSubmenu = [[MenuListController alloc] initWithMenuItem:newItem andSplitViewController:nil];
    newSubmenu.navigationDelegate = self;
    
    [menuNavController pushViewController:newSubmenu animated:YES];
    menuNavController.navigationBar.topItem.leftBarButtonItem = backButton;
    menuNavController.navigationBar.topItem.title = [newItem menuTitle];
    
    if( [newItem showAddButton] )
    {
        UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)] autorelease];
        menuNavController.navigationBar.topItem.rightBarButtonItem = addButton;
    }
    
    [backButton release];
}

- (void)showDetailController:(UIViewController<NavigationSource>*)subController
{
    if( self.splitViewController && [[self.splitViewController viewControllers] count] == 2 )
    {
        DetailNavController<NavigationSource> *controllerDetail = [[self.splitViewController viewControllers] objectAtIndex:1];
        [controllerDetail changeSection:subController];
    }
}

#pragma mark - actions callbacks

-(void)back:(id)sender
{
    [menuNavController popViewControllerAnimated:YES];
    [((UITableViewController*)menuNavController.topViewController).tableView reloadData];
}

-(void)returnToSection:(id)sender
{
    NSIndexPath *selected = ((MainMenuModel*)self.currentMenuItem).selectedRowIndex;
    
    if( !selected )
    {
        return;
    }
    
    CommonNavigationItem *newItem = [((CommonNavigationItem*)self.currentMenuItem) submenuNavigationItemForIndex:selected];
    
    if( !newItem )
    {
        return;
    }
    
    [self addItem:newItem forIndex:selected];
}

- (void)addButtonAction:(id)sender
{
    CommonNavigationItem *currentItem = (CommonNavigationItem*)self.currentMenuItem;
    UIViewController<NavigationSource> *subController = [currentItem createControllerForNewElement];
    
    if( !subController )
    {
        NSLog(@"Controller for new element not created");
        return;
    }
    
    DetailNavController<NavigationSource> *controllerDetail = [[self.splitViewController viewControllers] objectAtIndex:1];
    [controllerDetail changeSection:subController];

}

@end
