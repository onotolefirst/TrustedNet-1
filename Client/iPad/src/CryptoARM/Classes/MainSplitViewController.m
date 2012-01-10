//
//  MainSplitViewController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainSplitViewController.h"

#import "MenuNavigationController.h"
#import "DetailNavController.h"

#import "Wizard/WizardEncryptViewController.h"


@implementation MainSplitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
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
        
    MenuNavigationController *mainMenu = [[MenuNavigationController alloc] init];
    DetailNavController *detailController = [[DetailNavController alloc] init];
    detailController.wantsFullScreenLayout = TRUE;
    
    self.delegate = detailController;
    self.viewControllers = [NSArray arrayWithObjects:mainMenu, detailController, nil];
    [detailController.view layoutIfNeeded];
    
    [mainMenu release];
    [detailController release];
}

-(void)setDetailViewController:(UIViewController<NavigationSource>*)subViewController
{
    if( [self.viewControllers count] == 2 )
    {
        DetailNavController<NavigationSource> *controllerDetail = [self.viewControllers objectAtIndex:1];
        [controllerDetail changeSection:subViewController];
    }    
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
