//
//  MenuListController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuListController.h"

#import "MainMenuModel.h"
#import "DetailNavController.h"

@implementation MenuListController
@synthesize menuModel;
@synthesize navigationDelegate;

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (id)initWithMenuItem:(CommonNavigationItem*)menuItem
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.menuModel = menuItem;
        
        searchBar = [[UISearchBar alloc] init];
        searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        
        if( [menuItem filterable] )
        {
            searchController.delegate = self;
            searchController.searchResultsDataSource = self;
            searchController.searchResultsDelegate = self;
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

- (void)dealloc {
    [searchBar release];
    [searchController release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    if( [menuModel filterable] )
    {
        searchBar.frame = CGRectMake(0, -44, self.tableView.bounds.size.width, 44);
        searchBar.tintColor = [UIColor colorWithRed:(CGFloat)187/255 green:(CGFloat)2/255 blue:(CGFloat)4/255 alpha:1];
        
        self.tableView.tableHeaderView = searchBar;
        self.tableView.contentOffset = CGPointMake(0, 44);
        
        NSArray *arrScopes = [self.menuModel dataScopes];
        if( arrScopes )
        {
            searchBar.scopeButtonTitles = arrScopes;
            if( [searchBar respondsToSelector:@selector(setCombinesLandscapeBars:)] )
            {
                [searchBar performSelector:@selector(setCombinesLandscapeBars:)];
            }
        }
        searchBar.showsScopeBar = NO;
    }
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

#pragma mark - Search display delegate and search bar delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [menuModel applyFilterForSeachText:searchString andScope:searchBar.selectedScopeButtonIndex];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [menuModel applyFilterForSeachText:searchBar.text andScope:searchOption];
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    //NSLog(@"Search START detected");
    menuModel.filtered = YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    //NSLog(@"Search END detected");
    menuModel.filtered = NO;
    searchBar.showsScopeBar = YES;
    [self.tableView reloadData];
}

#pragma mark - table view delegate and data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [menuModel mainMenuSections];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuModel mainMenuRowsInSection:section];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [menuModel dequeOrCreateDefaultCell:tableView];
    return [menuModel fillCell:cell atIndex:indexPath inTableView:self.tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellAccessoryType elementType = [menuModel typeOfElementAt:indexPath];
    
    //TODO: change action selection
    if( UITableViewCellAccessoryNone == elementType )
        return;
    
    if( UITableViewCellAccessoryDisclosureIndicator == elementType )
    {
        CommonNavigationItem *newItem = [menuModel submenuNavigationItemForIndex:indexPath];
        
        if( !newItem )
        {
            NSLog(@"Error: Unable to get submenu for this item");
            return;
        }
        
        if( self.navigationDelegate )
        {
            [self.navigationDelegate addItem:newItem forIndex:indexPath];
        }
        else
        {
            NSLog(@"Warning: navigationDelegate is not setted");
        }
    }
    
    if( UITableViewCellAccessoryDetailDisclosureButton == elementType )
    {
        if( self.navigationDelegate )
        {
            [self.navigationDelegate showDetailController:[menuModel getDetailControllerForElementAt:indexPath]];
        }
        else
        {
            NSLog(@"Warning: navigationDelegate is not setted");
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [menuModel cellHeight:indexPath];
}

- (UITableView*)currentTableView
{
    return (menuModel.filtered ? self.searchDisplayController.searchResultsTableView : self.tableView);
}

@end
