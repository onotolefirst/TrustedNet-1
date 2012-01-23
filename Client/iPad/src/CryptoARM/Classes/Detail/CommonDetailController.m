//
//  CommonDetailController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CommonDetailController.h"

#import "CommonNavigationItem.h"
#import "MenuNavigationController.h"


@implementation CommonDetailController

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

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

- (void)setParentNavigationController:(UIViewController*)navController
{
    parentNavController = (DetailNavController*)navController;
}

- (id<MenuDataRefreshinProtocol>*)getSavingObject
{
    UIViewController<NavigationSource> *navSrc = (UIViewController<NavigationSource> *)self;

    if( !parentNavController || !(parentNavController.splitViewController) || ([parentNavController.splitViewController.viewControllers count] < 1) )
    {
        return [navSrc createSavingObject];
    }

    MenuNavigationController *navController = [parentNavController.splitViewController.viewControllers objectAtIndex:0];
    
    CommonNavigationItem *tmpItem = [navController currentMenuItem];
    CommonNavigationItem<MenuDataRefreshinProtocol> *dataSaveObject = nil;
        
    if( [self conformsToProtocol:@protocol(NavigationSource)] )
    {
        if( [tmpItem isKindOfClass:[navSrc getSavingObjcetClass]] )
        {
            dataSaveObject = (CommonNavigationItem<MenuDataRefreshinProtocol>*)tmpItem;
        }
        else
        {
            dataSaveObject = (CommonNavigationItem<MenuDataRefreshinProtocol>*)[navSrc createSavingObject];
        }
    }
    
    if( ![dataSaveObject conformsToProtocol:@protocol(MenuDataRefreshinProtocol)] )
    {
        return nil;
    }
    
    return (id<MenuDataRefreshinProtocol>*)dataSaveObject;
}

- (CGRect)getKeyboardPosition
{
    return parentNavController.lastDetectedKeyboardPosition;
}

@end
