//
//  SaveDelButtonsPanelController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KeyboardPositionDelegate.h"

@interface SaveDelButtonsPanelController : UIViewController
{
    NSString *delButtonTitle;
    NSString *saveButtonTitle;
    SEL delActionSelector;
    SEL saveActionSelector;
    id targetObject;
    
    NSArray *firstResponders;

    BOOL isEditing;
    CGRect keyboardCoordinates;
}

- (id)initWithSaveAction:(SEL)saveAction andDelAction:(SEL)delAction forObject:(id)target;
- (id)initWithSaveAction:(SEL)saveAction delAction:(SEL)delAction forObject:(id)target saveTitle:(NSString*)saveTitle delTitle:(NSString*)delTitle;

@property (retain, nonatomic) IBOutlet UIButton *delButton;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;

@property (retain, nonatomic) id<KeyboardPositionDelegate> keyboardPositionDelegate;

- (void)moveButtonsByInfo:(NSDictionary*)userInfo;

- (IBAction)delButtonTouchUpInsideAction:(id)sender;
- (IBAction)saveButtonTouchUpInsideAction:(id)sender;

- (void)setKeyboardResponders:(NSArray*)responders;

- (void)keyboardNotificationHandler:(NSNotification*)notification;
- (void)keyboardShowNotificationHandler:(NSNotification*)notification;
- (void)keyboardHideNotificationHandler:(NSNotification*)notification;
- (void)TextBeginEditingNotificationHandler:(NSNotification*)notification;
@end
