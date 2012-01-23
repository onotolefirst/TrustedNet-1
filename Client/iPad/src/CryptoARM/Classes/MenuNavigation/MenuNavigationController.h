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

@interface MenuNavigationController : UIViewController <MenuNavigationDelegate>
{
    UINavigationController *menuNavController;
}

@property (nonatomic, readonly) CommonNavigationItem<MenuDataRefreshinProtocol> *currentMenuItem;

- (void)reloadMenuData;
- (CommonNavigationItem<MenuDataRefreshinProtocol>*)currentMenuItem;

- (void)addItem:(CommonNavigationItem*)newItem forIndex:(NSIndexPath*)currentIndex;


@end
