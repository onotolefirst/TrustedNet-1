//
//  SettingsMenuViewController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsMenuViewController.h"

@implementation SettingsMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    popoverBar = [[UINavigationBar alloc] init];
    menuTable = [[UITableView alloc] init];
    
    popoverBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
    menuTable.frame = CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44);
    
    popoverBar.barStyle = UIBarStyleBlackOpaque;
    
    [self.view addSubview:popoverBar];
    [self.view addSubview:menuTable];
    
    menuTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    popoverBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    [popoverBar release];
    [menuTable release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)applyMenuSource:(SettingsMenuSource*)source
{
    if( !popoverBar.topItem )
    {
        [popoverBar pushNavigationItem:[[[UINavigationItem alloc] init] autorelease] animated:NO];
    }

    popoverBar.topItem.title = source.menuTitle;
    menuTable.delegate = source;
    menuTable.dataSource = source;
}

- (CGFloat)calculateMenuHeight
{
    [menuTable reloadData];
    return [menuTable rowHeight] * ([menuTable numberOfRowsInSection:0] + 1);
}

@end
