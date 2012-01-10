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
    
    //TODO: localize
    settingsMenu = [[SettingsMenuSource alloc] initWithTitle:@"Сервисы приложения"];
    
    [settingsMenu addMenuItem:@"Сервисы приложения" withAction:nil forTarget:nil];
    
    [settingsMenu addMenuItem:@"Адресная книга" withAction:nil forTarget:nil];
    [settingsMenu addMenuItem:@"Обсуждение идей" withAction:nil forTarget:nil];
    [settingsMenu addMenuItem:@"Журнал операций" withAction:nil forTarget:nil];
    [settingsMenu addMenuItem:@"Описание программы" withAction:nil forTarget:nil];
    [settingsMenu addMenuItem:@"Техподдержка" withAction:nil forTarget:nil];
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

- (UINavigationItem<MenuDataRefreshinProtocol>*)createSavingObject
{
    return nil;
}

@end
