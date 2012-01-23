//
//  RootViewController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#import "MessagesDetailController.h"
#import "StatisticsPanel.h"
#import "CustomFoldingButton.h"

@implementation RootViewController

- (id)initController
{
    {
        UIViewController* topController = [[MessagesDetailController alloc] init];
        UIViewController* bottomController = [[StatisticsPanel alloc] init];
        bottomController.view.autoresizesSubviews = TRUE;
        
        CustomFoldingButton *customButton = [[CustomFoldingButton alloc] init];
        
        //Attention! Panels for refreshing must support protocol RefreshingProtocol
        customButton.panelsForRefresh = [NSArray arrayWithObjects:topController, bottomController, nil];
        
        self = [super initWithTopPanel:topController bottomPanel:bottomController andCustomButton:customButton];

        [customButton release];
        [topController release];
        [bottomController release];
    }
    
    if (self) {
        [self constructSettingsMenu];
    }
    return self;
}

- (void)dealloc
{
    [settingsMenu release];
    [super dealloc];
}

- (void)constructSettingsMenu
{
    if( settingsMenu )
    {
        return;
    }
    
    settingsMenu = [[SettingsMenuSource alloc] initWithTitle:NSLocalizedString(@"ROOT_APPLICATION_CERVICES", @"Сервисы приложения")];
    
    [settingsMenu addMenuItem:NSLocalizedString(@"ROOT_APPLICATION_CERVICES", @"Сервисы приложения") withAction:nil forTarget:nil];
    
    [settingsMenu addMenuItem:NSLocalizedString(@"ROOT_ADDRES_BOOK", @"Адресная книга") withAction:nil forTarget:nil];
    [settingsMenu addMenuItem:NSLocalizedString(@"ROOT_IDEAS_DISCUSSION", @"Обсуждение идей") withAction:nil forTarget:nil];
    [settingsMenu addMenuItem:NSLocalizedString(@"ROOT_OPERATIONS_LOG", @"Журнал операций") withAction:nil forTarget:nil];
    [settingsMenu addMenuItem:NSLocalizedString(@"ROOT_PROGRAM_DESCRIPTION", @"Описание программы") withAction:nil forTarget:nil];
    [settingsMenu addMenuItem:NSLocalizedString(@"ROOT_TECH_SUPPORT", @"Техподдержка") withAction:nil forTarget:nil];
}

#pragma mark - NavigationSource protocol supporting

+ (NSString*)itemTag
{
    return @"RootViewController";
}

- (NSString*)itemTag
{
    return [RootViewController itemTag];
}

- (NSString*)title
{
    return NSLocalizedString(@"CRYPTOARM", @"CRYPTOARM");
}

- (NSArray*)getAdditionalButtons
{
    return nil;
}

- (void)setParentNavigationController:(UIViewController*)navController
{
    
}

- (BOOL)preserveController
{
    return FALSE;
}

- (SettingsMenuSource*)settingsMenu
{
    return settingsMenu;
}

- (Class)getSavingObjcetClass
{
    return [self class];
}

- (id<MenuDataRefreshinProtocol>*)createSavingObject
{
    return nil;
}

@end
