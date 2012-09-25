//
//  ViewControllerWithFlipPanel.m
//  Test-flip-panel
//
//  Created by Sergey Mityukov on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewControllerWithFlipPanel.h"

#import "FlipPanelView.h"


@implementation ViewControllerWithFlipPanel

- (void)displayViews
{
    NSUInteger controllersCount = [viewControllersArray count];
    
    if( controllersCount != 2 && controllersCount != 3 )
    {
        NSLog(@"Warning: Controller not initialized by necessary subviews (top and bottom views)");
        return;
    }
    
    UIView *button = (controllersCount == 3) ? ((UIViewController*)[viewControllersArray objectAtIndex:2]).view : nil;
    
    [(FlipPanelView*)self.view setTopSubview:((UIViewController*)[viewControllersArray objectAtIndex:0]).view bottomSubview:((UIViewController*)[viewControllersArray objectAtIndex:1]).view andButtonSubview:button];
}

- (id)initWithTopPanel:(UIViewController*)topPanel andBottomPanel:(UIViewController*)bottomPanel
{
    self = [super init];
    
    if( self )
    {
        self.panelFlipped = FLIP_DEFAULT_STATE;
        self.bottomPanelShare = DEFAULT_BOTTOM_PANEL_SHARE;
        
        self.viewControllers = [NSArray arrayWithObjects:topPanel, bottomPanel, nil];
        
        if ( [controllerRootView retainCount] )
        {
            [controllerRootView release];
        }
        
        controllerRootView = [[FlipPanelView alloc] initWithFrame:self.view.frame];
    }
    
    return self;
}

- (void)handlePushAction:(id)sender
{
    [(FlipPanelView*)self.view buttonPressAction:sender];
}

- (id)initWithTopPanel:(UIViewController*)topPanel bottomPanel:(UIViewController*)bottomPanel andCustomButton:(UIViewController*)customButton
{
    self = [super init];
    
    if( self )
    {
        self.panelFlipped = FLIP_DEFAULT_STATE;
        self.bottomPanelShare = DEFAULT_BOTTOM_PANEL_SHARE;

        self.viewControllers = [NSArray arrayWithObjects:topPanel, bottomPanel, customButton, nil];
        
        if ( [controllerRootView retainCount] )
        {
            [controllerRootView release];
        }

        controllerRootView = [[FlipPanelView alloc] initWithFrame:self.view.frame];
    }
    
    return self;
}

- (NSArray*)viewControllers
{
    return viewControllersArray;
}

- (void)setViewControllers:(NSArray *)controllers
{
    if(viewControllersArray)
    {
        [viewControllersArray release];
    }

    viewControllersArray = [[NSArray alloc] initWithArray:controllers copyItems:NO];
    [self displayViews];
}

- (NSInteger)bottomPanelShare
{
    return bottomPanelShare;
}

- (void)setBottomPanelShare:(NSInteger)newBottomPanelShare
{
    bottomPanelShare = newBottomPanelShare;
    ((FlipPanelView*)self.view).bottomPanelShare = bottomPanelShare;
}

- (void)setTitleForOpenedButton:(NSString*)openedTitle andClosedButton:(NSString*)closedTitle
{
    [((FlipPanelView*)self.view) setTitleForOpenedButton:openedTitle andClosedButton:closedTitle];
}

- (BOOL)panelFlipped
{
    return panelFlipped;
}

- (void)setPanelFlipped:(BOOL)panelFlipState
{
    panelFlipped = panelFlipState;
    ((FlipPanelView*)self.view).panelFlipped = panelFlipped;
}

- (void)setFlippedState:(BOOL)flipped andPanelShare:(NSInteger)share withAnimation:(BOOL)animate
{
    panelFlipped = flipped;
    bottomPanelShare = share;
    [((FlipPanelView*)self.view) setFlippedState:panelFlipped andPanelShare:bottomPanelShare withAnimation:animate];
}

- (void)dealloc
{
    if(viewControllersArray)
    {
        [viewControllersArray release];
    }
    
    [controllerRootView removeFromSuperview];
    [controllerRootView release];
    
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

    if ( [controllerRootView retainCount] )
    {
        [controllerRootView release];
    }

    controllerRootView = [[FlipPanelView alloc] initWithFrame:self.view.frame];
    self.view = controllerRootView;
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
