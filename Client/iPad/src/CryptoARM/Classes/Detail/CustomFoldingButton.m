//
//  CustomFoldingButton.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomFoldingButton.h"

#import "FlipPanelView.h"
#import "RefreshingProtocol.h"


@implementation CustomFoldingButton
@synthesize buttonsBar;
@synthesize panelTitle;
@synthesize progressItem;
@synthesize activityIndicator;
@synthesize panelsForRefresh;

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
    if(refreshingThread)
    {
        [refreshingThread release];
    }
    
    [buttonsBar release];
    [panelTitle release];
    [progressItem release];
    [activityIndicator release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    panelTitle.title = @"Статистика";
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    if( [activityIndicator respondsToSelector:@selector(setColor:)] )
    {//supported in iOS 5 and later
        activityIndicator.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    }
    progressItem.customView = activityIndicator;
}

- (void)viewDidUnload
{
    [self setButtonsBar:nil];
    [self setPanelTitle:nil];
    [self setProgressItem:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)flipHandler:(id)sender
{
    FlipPanelView* parentPanel = (FlipPanelView*)self.view.superview;
    [parentPanel setFlippedState:!parentPanel.panelFlipped andPanelShare:parentPanel.bottomPanelShare withAnimation:YES];
}

- (IBAction)flipAction:(id)sender {
    [self flipHandler:sender];
}

- (IBAction)refreshAction:(id)sender {
    //TODO: reorganize threads
    if( refreshingThread && [refreshingThread isExecuting] )
    {
        return;
    }
    
    if(refreshingThread)
    {
        [refreshingThread release];
    }

    refreshingThread = [[NSThread alloc] initWithTarget:self selector:@selector(refreshInfo) object:nil];
    [activityIndicator startAnimating];
    [refreshingThread start];
}

- (void)refreshInfo
{
    //TODO: catch exceptions
//    @try
//    {
        for( int i = 0; i < [panelsForRefresh count]; i++)
        {
            id panel = [panelsForRefresh objectAtIndex:i];
            if( [panel conformsToProtocol:@protocol(RefreshingProtocol)] )
            {
                [[panelsForRefresh objectAtIndex:i] refreshContent];
            }
        }
        
        //TODO: remove test delay
        sleep(1);
//    }
//    @catch (NSException *exception)
//    {
//        //<#handler#>
//        [activityIndicator stopAnimating];
//    }
//    @finally
//    {
//        //<#statements#>
//    }

    [activityIndicator stopAnimating];
}

@end
