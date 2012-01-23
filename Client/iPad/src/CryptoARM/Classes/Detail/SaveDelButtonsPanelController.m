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
@synthesize keyboardPositionDelegate;

- (id)initWithSaveAction:(SEL)saveAction andDelAction:(SEL)delAction forObject:(id)target
{
    self = [self initWithSaveAction:saveAction delAction:delAction forObject:target saveTitle:NSLocalizedString(@"SAVE_BUTTON_TITLE", @"Сохранить") delTitle:NSLocalizedString(@"DELETE_BUTTON_TITLE", @"Удалить")];
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
        //TODO: check, what control is really first responder
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
    //TODO: if exists, free previos array
    firstResponders = [NSArray arrayWithArray:responders];
    [firstResponders retain];
    
    for (UITextField *textField in firstResponders) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextBeginEditingNotificationHandler:) name:UITextFieldTextDidBeginEditingNotification object:textField];
    }
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

- (void)moveButtonsByInfo:(NSDictionary*)userInfo
{
    CGRect windowRelatedKeyboardCoords = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if( !(windowRelatedKeyboardCoords.size.width + windowRelatedKeyboardCoords.size.height) )
{
        NSLog(@"Unable get new coordinates");
        return;
    }
        
    UIWindow *wnd = self.view.window;
    keyboardCoordinates = [self.view.superview convertRect:windowRelatedKeyboardCoords fromView:wnd];
    CGFloat animDuration = (isEditing ? ((NSNumber*)[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]).floatValue : 0);
    
    [UIView animateWithDuration:animDuration animations:^{
            [self resizeButtonsBarFrame];
        }];
}

- (void)keyboardNotificationHandler:(NSNotification *)notification
{
    [self moveButtonsByInfo:notification.userInfo];
}

- (void)keyboardShowNotificationHandler:(NSNotification*)notification
{
    [self moveButtonsByInfo:notification.userInfo];
}

- (void)keyboardHideNotificationHandler:(NSNotification*)notification
{
    [self keyboardNotificationHandler:notification];
}

- (void)TextBeginEditingNotificationHandler:(NSNotification*)notification
{
    if( !isEditing && self.keyboardPositionDelegate )
    {
        keyboardCoordinates = [self.view.superview convertRect:[self.keyboardPositionDelegate getKeyboardPosition] fromView:self.view.window];
        [self resizeButtonsBarFrame];
    }
    
    isEditing = YES;
    
    self.view.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 1;
    }];
}

@end
