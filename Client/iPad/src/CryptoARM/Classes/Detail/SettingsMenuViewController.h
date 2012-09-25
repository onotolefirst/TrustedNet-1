//
//  SettingsMenuViewController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SettingsMenuSource.h"

@interface SettingsMenuViewController : UIViewController
{
    UINavigationBar *popoverBar;
    UITableView *menuTable;
}

- (void)applyMenuSource:(SettingsMenuSource*)source;
- (CGFloat)calculateMenuHeight;

@end
