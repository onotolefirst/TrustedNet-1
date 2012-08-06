//
//  RootViewController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NavigationSource.h"
#import "ViewControllerWithFlipPanel.h"

@interface RootViewController : ViewControllerWithFlipPanel <NavigationSource>
{
    SettingsMenuSource *settingsMenu;
}

- (id)initController;
- (void)dealloc;

- (void)constructSettingsMenu;

@end
