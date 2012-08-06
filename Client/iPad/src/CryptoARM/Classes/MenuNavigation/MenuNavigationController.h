//
//  MenuNavigationController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CommonNavigationItem.h"
#import "MenuNavigationDelegate.h"
#include "MainSplitViewController.h"

@interface MenuNavigationController : UIViewController <MenuNavigationDelegate>
{
    @public UINavigationController *menuNavController;
}

@property (nonatomic, readonly) CommonNavigationItem<MenuDataRefreshinProtocol> *currentMenuItem;
@property (nonatomic, retain) UINavigationController *menuNavController;

- (void)reloadMenuData;
- (CommonNavigationItem<MenuDataRefreshinProtocol>*)currentMenuItem;

- (void)addItem:(CommonNavigationItem*)newItem forIndex:(NSIndexPath*)currentIndex;


@end
