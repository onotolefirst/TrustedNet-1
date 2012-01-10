//
//  MenuNavigationController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuNavigationController.h"

#import "MainMenuModel.h"
#import "DetailNavController.h"


@implementation MenuNavigationController
@synthesize navBar;
@synthesize tableMenu;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithTable:(UITableView *)tblView andNavigationBar:(UINavigationBar *)navigationBar
{
    self = [super init];
    if(self)
    {
        [navBar release];
        [tableMenu release];
        
        navBar = navigationBar;
        tableMenu = tblView;
    }
    return self;
}

- (void)dealloc
{
    [navBar release];
    [tableMenu release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)reloadMenuData
{
    [tableMenu reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    tableMenu.dataSource = self;
    tableMenu.delegate = self;
    
    MainMenuModel *rootItem = [[MainMenuModel alloc] init];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.action = @selector(returnToSection:);
    backButton.target = self;
    backButton.image = [UIImage imageNamed:@"to-section.PNG"];
    
    [rootItem setLeftBarButtonItem:backButton];
    navBar.items = [NSArray arrayWithObject:rootItem];
    
    [rootItem release];
    [backButton release];
    
    [tableMenu reloadData];
}

- (void)viewDidUnload
{
    [self setNavBar:nil];
    [self setTableMenu:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

//--------datasource and delegate methods-----------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [((CommonNavigationItem*)navBar.topItem) mainMenuSections];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [((CommonNavigationItem*)navBar.topItem) mainMenuRowsInSection:section];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommonNavigationItem* navItm = (CommonNavigationItem*)navBar.topItem;
    
    UITableViewCell *cell = [navItm dequeOrCreateDefaultCell:tableView];
    return [navItm fillCell:cell atIndex:indexPath inTableView:tableMenu];
}

- (void)addItem:(CommonNavigationItem*)newItem forIndex:(NSIndexPath*)currentIndex
{
    [tableMenu deselectRowAtIndexPath:currentIndex animated:YES];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.action = @selector(back:);
    backButton.target = self;
    backButton.image = [UIImage imageNamed:@"to-root.PNG"];
    
    if( [newItem showAddButton] )
    {
        UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)] autorelease];
        [newItem setRightBarButtonItem:addButton];
    }
    
    [newItem setLeftBarButtonItem:backButton];
    [navBar pushNavigationItem:newItem animated:YES];
    [tableMenu reloadSections:[NSIndexSet indexSetWithIndex:currentIndex.section] withRowAnimation:UITableViewRowAnimationLeft];
    [backButton release];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommonNavigationItem *currentItem = (CommonNavigationItem*)navBar.topItem;
    
    UITableViewCellAccessoryType elementType = [currentItem typeOfElementAt:indexPath];
    
    if( UITableViewCellAccessoryNone == elementType )
        return;
    
    if( UITableViewCellAccessoryDisclosureIndicator == elementType )
    {
        CommonNavigationItem *newItem = [currentItem submenuNavigationItemForIndex:indexPath];
        
        if( !newItem )
        {
            NSLog(@"Error: Unable to get submenu for this item");
            return;
        }
        
        [self addItem:newItem forIndex:indexPath];
    }
    
    if( (UITableViewCellAccessoryDetailDisclosureButton == elementType) && self.splitViewController && [[self.splitViewController viewControllers] count] == 2 )
    {
        UIViewController<NavigationSource> *subController = [currentItem getDetailControllerForElementAt:indexPath];
        
        DetailNavController<NavigationSource> *controllerDetail = [[self.splitViewController viewControllers] objectAtIndex:1];
        [controllerDetail changeSection:subController];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [((CommonNavigationItem*)navBar.topItem) cellHeight:indexPath];
}

#pragma mark - actions callbacks

-(void)back:(id)sender
{
    [navBar popNavigationItemAnimated:YES];
    [tableMenu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
}

-(void)returnToSection:(id)sender
{
    NSIndexPath *selected = ((MainMenuModel*)navBar.topItem).selectedRowIndex;
    
    if( !selected )
    {
        return;
    }
    
    CommonNavigationItem *newItem = [((CommonNavigationItem*)navBar.topItem) submenuNavigationItemForIndex:selected];
    
    if( !newItem )
    {
        return;
    }
    
    [self addItem:newItem forIndex:selected];
}

- (void)addButtonAction:(id)sender
{
    CommonNavigationItem *currentItem = (CommonNavigationItem*)navBar.topItem;
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
