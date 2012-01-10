//
//  CommonDetailController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailNavController.h"


@interface CommonDetailController : UIViewController
{
    DetailNavController *parentNavController;
}

- (void)setParentNavigationController:(DetailNavController*)navController;
- (UINavigationItem<MenuDataRefreshinProtocol>*)getSavingObject;

@end
