//
//  DetailNavController.h
//  Test-customNavController2
//
//  Created by Sergey Mityukov on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NavigationSource.h"

#define SETTINGS_BUTTON_TAG 123

@interface DetailNavController : UIViewController <UINavigationControllerDelegate, UISplitViewControllerDelegate>
{
    NSMutableArray *preservedControllers;
    UIPopoverController *settingsMenuPopover;
    UIPopoverController *mainMenuPopover;
}

@property (retain, nonatomic) UINavigationController *navCtrlr;
@property (retain, nonatomic) UIPopoverController *mainMenuPopover;

- (void)pushNavController:(UIViewController<NavigationSource>*)newController;
- (void)changeSection:(UIViewController<NavigationSource>*)newController;

//- (BOOL)tryPushByTag:(NSString*)itemTag;
- (BOOL)tryChangeSectionByTag:(NSString*)itemTag;

- (void)dismissPopovers;

- (void)settingsButtonAction:(id)sender;

- (void)refreshMenuData;

@end
