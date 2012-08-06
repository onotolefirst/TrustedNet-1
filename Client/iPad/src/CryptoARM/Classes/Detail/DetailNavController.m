//
//  DetailNavController.m
//  Test-customNavController2
//
//  Created by Sergey Mityukov on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailNavController.h"

#import "RootViewController.h"
#import "SettingsMenuViewController.h"
#import "MenuNavigationController.h"


@implementation DetailNavController
@synthesize navCtrlr;
@synthesize mainMenuPopover;
@synthesize lastDetectedKeyboardPosition;

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

#pragma mark - Hidden methods

- (UIViewController<NavigationSource>*)getPreservedControllerByTag:(NSString*)itemTag
{
    if( !preservedControllers )
    {
        return nil;
    }
    
    NSUInteger cnt = [preservedControllers count];
    
    for( NSUInteger i = 0; i < cnt; i++ )
    {
        UIViewController<NavigationSource> *ctrlr = [preservedControllers objectAtIndex:i];
        if( [itemTag isEqualToString:[ctrlr itemTag]] )
        {
            return ctrlr;
        }
    }
    
    return nil;
}

- (void)addButtonsFromController:(UIViewController<NavigationSource>*)newController
{
    NSMutableArray *rightButtons = nil, *leftButtons = nil;
    NSArray *additionalButtons = [newController getAdditionalButtons];
    
    leftButtons = [[NSMutableArray alloc] init];
    rightButtons = [[NSMutableArray alloc] init];
    
    if(additionalButtons)
    {
        NSMutableArray *currArray;
        for (NSUInteger i = 0; i < [additionalButtons count]; i++)
        {
            UIBarButtonItem *button = [additionalButtons objectAtIndex:i];
            currArray = ((button.image || button.customView) ? leftButtons : rightButtons);
            [currArray addObject:button];
        }
    }
    
    NSMutableArray *gatheredButtons = [[NSMutableArray alloc] init];
    
    [gatheredButtons addObjectsFromArray:leftButtons];
    
    //Prepare settings button
    if( [newController settingsMenu] )
    {
        UIBarButtonItem *settingsButton;
        
        settingsButton = [[UIBarButtonItem alloc] init];
        settingsButton.action = @selector(settingsButtonAction:);
        settingsButton.target = self;
        settingsButton.image = [UIImage imageNamed:@"gear.png"];
        settingsButton.style = UIBarButtonItemStylePlain;
        settingsButton.tag = SETTINGS_BUTTON_TAG;
        
        [gatheredButtons addObject:settingsButton];
        [settingsButton release];
    }
    
    [gatheredButtons addObjectsFromArray:rightButtons];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [gatheredButtons insertObject:spaceItem atIndex:0];
    
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.items = gatheredButtons;
    toolBar.frame = CGRectMake(0, 0, 44 * [gatheredButtons count], 44);
    toolBar.tintColor = navCtrlr.navigationBar.tintColor;
    
    UIBarButtonItem *customizedItem = [[UIBarButtonItem alloc] initWithCustomView:toolBar];
    navCtrlr.navigationBar.topItem.rightBarButtonItem = customizedItem;
    
    [customizedItem release];
    [toolBar release];
    [spaceItem release];
    
    [rightButtons release];
    [leftButtons release];
    [gatheredButtons release];
}

- (void)prepareItem:(UIViewController<NavigationSource>*)newController
{
    [navCtrlr pushViewController:newController animated:YES];
    
    //TODO: renewing problem. Crash error with navigation controller delegate
    //  see method navigationController of ParametersPanel class
    
//    if( [newController conformsToProtocol:@protocol(UINavigationControllerDelegate)] && [newController respondsToSelector:@selector(navigationController:willShowViewController:animated:)] )
//    {
//        navCtrlr.delegate = (id<UINavigationControllerDelegate>)newController;
//    }
    
    
    if( ![newController conformsToProtocol:@protocol(NavigationSource)] )
    {
        NSLog(@"Warning! View controller not conforms to reqired protocol NavigationSource");
        return;
    }
    
    navCtrlr.navigationBar.topItem.title = [newController title];
    [newController setParentNavigationController:self];
    
    //add buttons
    [self addButtonsFromController:newController];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view addSubview:navCtrlr.view];
    
    SettingsMenuViewController *settingsMenu = [[SettingsMenuViewController alloc] init];
    settingsMenuPopover = [[UIPopoverController alloc] initWithContentViewController:settingsMenu];
    [settingsMenu release];
    
    RootViewController *defaultController = [[RootViewController alloc] initController];
    defaultController.bottomPanelShare = 50;
    navCtrlr = [[UINavigationController alloc] initWithRootViewController:defaultController];
    
    navCtrlr.delegate = self;
    navCtrlr.navigationBar.topItem.title = NSLocalizedString(@"CRYPTOARM", @"CryptoARM");
    navCtrlr.navigationBar.tintColor = [UIColor colorWithRed:(CGFloat)187/255 green:(CGFloat)2/255 blue:(CGFloat)4/255 alpha:1];
    
    [self addButtonsFromController:defaultController];
    [defaultController release];
    
    [self.view addSubview:navCtrlr.view];
    
    self.lastDetectedKeyboardPosition = CGRectMake(0, 0, 0, 0);
    keyboardIsSplitted = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectingKeyboardPosition:) name:UIKeyboardDidShowNotification object:nil];
    
    if( [[UIDevice currentDevice].systemVersion compare:@"5.0"] != NSOrderedAscending )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectingSplittedKeyboardPosition:) name:UIKeyboardDidChangeFrameNotification object:nil];
    }
}

- (void)viewDidUnload
{
    [self setNavCtrlr:nil];
    [self setMainMenuPopover:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

//- (void)viewDidLayoutSubviews
//{
//    
//}

- (void)dealloc {
    if( preservedControllers )
    {
        [preservedControllers release];
    }
    
    if( settingsMenuPopover )
    {
        // ifit was previously opened and not closed...
        [settingsMenuPopover dismissPopoverAnimated:YES];
    }

    [settingsMenuPopover release];
    [mainMenuPopover release];
    
    [navCtrlr release];
    [super dealloc];
}

#pragma mark - Navigation supporting

- (void)pushNavController:(UIViewController<NavigationSource>*)newController
{
    //Preserving controller
    if([newController preserveController])
    {
        UIViewController<NavigationSource>  *oldController = [self getPreservedControllerByTag:[newController itemTag]];
        if( oldController )
        {
            [preservedControllers removeObject:oldController];
        }
        
        if( !preservedControllers )
        {
            preservedControllers = [[NSMutableArray alloc] initWithObjects:newController, nil];
        }
        else
        {
            [preservedControllers addObject:newController];
        }
    }

    [self prepareItem:newController];
}

- (void)changeSection:(UIViewController<NavigationSource>*)newController
{
    [navCtrlr popToRootViewControllerAnimated:NO];
    [self pushNavController:newController];
}

//- (BOOL)tryPushByTag:(NSString*)itemTag
//{
//    
//    return FALSE;
//}

- (BOOL)tryChangeSectionByTag:(NSString*)itemTag
{
    UIViewController<NavigationSource> *extractedController = [self getPreservedControllerByTag:itemTag];
    if( !extractedController )
    {
        NSLog(@"Controller is not preserved in array");
        return FALSE;
    }
    
    [navCtrlr popToRootViewControllerAnimated:NO];
    [self prepareItem:extractedController];
    return TRUE;
}

- (void)settingsButtonAction:(id)sender
{
    if( [navCtrlr.topViewController conformsToProtocol:@protocol(NavigationSource)] && ![(UIViewController<NavigationSource>*)(navCtrlr.topViewController) settingsMenu] )
    {
        NSLog(@"Error! Settings button added, but setting dialog not supported");
        return;
    }
    
    SettingsMenuSource *menuSource = [(UIViewController<NavigationSource>*)(navCtrlr.topViewController) settingsMenu];
    menuSource.menuPopover = settingsMenuPopover;

    SettingsMenuViewController *settingsMenu = (SettingsMenuViewController*)settingsMenuPopover.contentViewController;
    [settingsMenu applyMenuSource:menuSource];
    settingsMenuPopover.popoverContentSize = CGSizeMake(settingsMenuPopover.popoverContentSize.width, [settingsMenu calculateMenuHeight]);

    //searching settings button
    UIToolbar *bar = ((UIToolbar*)navCtrlr.navigationBar.topItem.rightBarButtonItem.customView);
    UIBarButtonItem *rectItem = (UIBarButtonItem*)bar;
    
    for( int i = 0; i < [bar.items count]; i++)
    {
        UIBarButtonItem *currentItem = [bar.items objectAtIndex:i];
        if( currentItem.tag == SETTINGS_BUTTON_TAG )
        {
            rectItem = currentItem;
            break;
        }
    }
    
    //hide main menu before settings menu displaying
    if( self.mainMenuPopover && self.mainMenuPopover.popoverVisible )
    {
        [self.mainMenuPopover dismissPopoverAnimated:YES];
    }
    
    UIViewController *topController = navCtrlr.topViewController;
    if( [topController respondsToSelector:@selector(dismissPopovers)] )
    {
        [((id<NavigationSource>)topController) dismissPopovers];
    }
    
    [settingsMenuPopover presentPopoverFromBarButtonItem:rectItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)dismissPopovers
{
    if( self.mainMenuPopover && self.mainMenuPopover.popoverVisible )
    {
        [self.mainMenuPopover dismissPopoverAnimated:YES];
    }

    if( settingsMenuPopover && settingsMenuPopover.popoverVisible )
    {
        [settingsMenuPopover dismissPopoverAnimated:YES];
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //Remove settings menu popover if view is changed (by navigation)
    if( !settingsMenuPopover.popoverVisible )
    {
        return;
    }
    
    [settingsMenuPopover dismissPopoverAnimated:animated];
}

#pragma mark - UISplitViewControllerDelegate protocol supporting

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = NSLocalizedString(@"MM_MENU", @"MM_MENU");
    ((UINavigationItem*)[navCtrlr.navigationBar.items objectAtIndex:0]).leftBarButtonItem = barButtonItem;
    self.mainMenuPopover = pc;
}

- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    ((UINavigationItem*)[navCtrlr.navigationBar.items objectAtIndex:0]).leftBarButtonItem = nil;
    self.mainMenuPopover = nil;
}

#pragma mark - Other functions

- (void)refreshMenuData
{
    MenuNavigationController *menuController = [self.splitViewController.viewControllers objectAtIndex:0];
    [menuController reloadMenuData]; 
}

- (void)detectingKeyboardPosition:(NSNotification*)notification
{
    self.lastDetectedKeyboardPosition = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardIsSplitted = NO;
}

- (void)detectingSplittedKeyboardPosition:(NSNotification*)notification
{
    NSLog(@"Keyboard frame changing detected.");
    self.lastDetectedKeyboardPosition = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardIsSplitted = YES;
}

@end
