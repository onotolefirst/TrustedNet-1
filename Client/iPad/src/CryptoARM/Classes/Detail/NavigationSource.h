//
//  NavigationSource.h
//  Test-customNavController2
//
//  Created by Sergey Mityukov on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SettingsMenuSource.h"

#import "MenuDataRefreshinProtocol.h"

@protocol NavigationSource <NSObject>

+ (NSString*)itemTag;
- (NSString*)itemTag;
- (NSString*)title;
- (NSArray*)getAdditionalButtons;
- (void)setParentNavigationController:(UIViewController*)navController;
- (BOOL)preserveController;
- (SettingsMenuSource*)settingsMenu;

- (Class)getSavingObjcetClass;
- (UINavigationItem<MenuDataRefreshinProtocol>*)createSavingObject;

@optional
- (void)dismissPopovers;
//- (void)setItemTag;
//- (void)setTitle;
//- (void)setPreserveController:(BOOL)preserve;

@end
