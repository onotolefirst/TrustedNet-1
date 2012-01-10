//
//  SaveDelButtonsPanelController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SaveDelButtonsPanelController.h"

@implementation SaveDelButtonsPanelController
@synthesize delButton;
@synthesize saveButton;

- (id)initWithSaveAction:(SEL)saveAction andDelAction:(SEL)delAction forObject:(id)target
{
    //TODO: localize
    self = [self initWithSaveAction:saveAction delAction:delAction forObject:target saveTitle:@"Сохранить" delTitle:@"Удалить"];
    if(self)
    {
        //additional init
    }
    return self;
}

- (id)initWithSaveAction:(SEL)saveAction delAction:(SEL)delAction forObject:(id)target saveTitle:(NSString*)saveTitle delTitle:(NSString*)delTitle
{
    self = [super init];
    if(self)
    {
        saveActionSelector = saveAction;
        delActionSelector = delAction;
        targetObject = target;
        delButtonTitle = delTitle;
        saveButtonTitle = saveTitle;
        
        firstResponders = nil;
    }
    return self;
}

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.wantsFullScreenLayout = YES;
    self.view.hidden = YES;
    self.view.alpha = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowNotificationHandler:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHideNotificationHandler:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setDelButton:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)delButtonTouchUpInsideAction:(id)sender
{
    if( ![targetObject performSelector:delActionSelector] )
    {
        return;
    }
    
    isEditing = FALSE;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
    }];
    
    if( firstResponders )
    {
        for( NSUInteger i = 0; i < [firstResponders count]; i++ )
        {
            [[firstResponders objectAtIndex:i] resignFirstResponder];
        }
    }
}

- (IBAction)saveButtonTouchUpInsideAction:(id)sender
{
    if( ![targetObject performSelector:saveActionSelector] )
    {
        return;
    }
    
    if( firstResponders )
    {
        for( NSUInteger i = 0; i < [firstResponders count]; i++ )
        {
            [[firstResponders objectAtIndex:i] resignFirstResponder];
        }
    }
    
    isEditing = FALSE;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
    }];

}

- (void)setKeyboardResponders:(NSArray*)responders
{
    firstResponders = [NSArray arrayWithArray:responders];
    [firstResponders retain];
}

- (void)dealloc {
    if( firstResponders )
    {
        [firstResponders release];
        firstResponders = nil;
    }
    [delButton release];
    [saveButton release];
    [super dealloc];
}

- (void)resizeButtonsBarFrame
{
    self.view.frame = CGRectMake(0, keyboardCoordinates.origin.y - 44, self.view.superview.bounds.size.width, 44);
}

- (void)keyboardNotificationHandler:(NSNotification *)notification
{
    CGRect windowRelatedKeyboardCoords = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIWindow *wnd = self.view.window;
    keyboardCoordinates = [self.view.superview convertRect:windowRelatedKeyboardCoords fromView:wnd];
    
    NSLog(@"Keyboard notification!!!");

    [UIView animateWithDuration:(isEditing ? 0.3 : 0) animations:^{
            [self resizeButtonsBarFrame];
        }];
}

- (void)keyboardShowNotificationHandler:(NSNotification*)notification
{
    [self keyboardNotificationHandler:notification];
    if( !isEditing )
    {
        self.view.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = 1;
        }];
    }
    isEditing = YES;
}

- (void)keyboardHideNotificationHandler:(NSNotification*)notification
{
    [self keyboardNotificationHandler:notification];
}

@end
