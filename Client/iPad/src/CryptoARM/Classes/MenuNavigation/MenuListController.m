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
@synthesize menuModel, navigationDelegate, mainSplitView;

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (id)initWithMenuItem:(CommonNavigationItem*)menuItem andSplitViewController:(MainSplitViewController *)svc
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.menuModel = menuItem;
        
      //  if (svc)
        {
            self.mainSplitView = svc;//[svc copy];
        }
        
        searchBar = [[UISearchBar alloc] init];
        searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        [self.tableView setTableHeaderView:menuItem.tblHeaderView];
        
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

- (void)dealloc
{
    [searchBar release];
    [searchController release];
    
   // if (mainSplitView)
    {
    //    [mainSplitView release];
    }
    
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
    NSString *strClassName = [[menuModel class] description];
    
    if ( ([strClassName isEqualToString:@"CertChainViewController"])
        || ([strClassName isEqualToString:@"ArchiveMenuModel"])
        || ([strClassName isEqualToString:@"MainMenuModel"]) )
    {
        if ([strClassName isEqualToString:@"ArchiveMenuModel"])
        {
            [(ArchiveMenuModel *)menuModel setParentNavigationController:[self navigationController]];
            [(ArchiveMenuModel *)menuModel setNavigationDelegate:self.navigationDelegate];

            [(ArchiveMenuModel *)menuModel selectRowAtIndexPath:indexPath inTableView:tableView];
        }

        CommonNavigationItem *newItem = [menuModel submenuNavigationItemForIndex:indexPath];

        if( newItem )
        {
            if( self.navigationDelegate )
            {
                if ([strClassName isEqualToString:@"ArchiveMenuModel"])
                {
                    UINavigationController *mainNavigationController = [self navigationController];

                    if (mainNavigationController)
                    {
                        // push menu subview controller(archive content table view)
                        MenuListController *subViewController = [[MenuListController alloc] initWithMenuItem:newItem andSplitViewController:nil];
                        subViewController.navigationDelegate = self.navigationDelegate;

                        [mainNavigationController pushViewController:subViewController animated:YES];                        
                        ArchiveMenuModel *someItem = (ArchiveMenuModel *)newItem;

                        UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(500, 0, 320, 40)];
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
                        [label setFont:[UIFont boldSystemFontOfSize:12.0]];
                        [label setBackgroundColor:[UIColor clearColor]];
                        [label setTextColor:[UIColor whiteColor]];
                        [label setText:[someItem.strFilename lastPathComponent]];
                        [labelView addSubview:label];

                        [mainNavigationController.navigationBar.topItem setTitleView:labelView];
                        //[mainNavigationController.navigationBar.topItem setTitle:[someItem.strFilename lastPathComponent]];

                        [label release];
                        [subViewController release];
                    }
                }
                else
                {
                    [self.navigationDelegate addItem:newItem forIndex:indexPath];
                }
            }
            else
            {
                NSLog(@"Warning: navigationDelegate is not setted");
            }
        }
        else
        {
            NSLog(@"Unable to get submenu for this item");
        }
    }
    
    if ( ([strClassName isEqualToString:@"CertificateUsageMenuModel"])
        || ([strClassName isEqualToString:@"CertMenuModel"]) )
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
