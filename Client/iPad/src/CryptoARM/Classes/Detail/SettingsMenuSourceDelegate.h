//
//  SettingsMenuSourceDelegate.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 02.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SettingsMenuSourceDelegate <NSObject>

// Methods for additional setup of menu cells
- (UITableViewCellAccessoryType)accessoryTypeForCell:(NSIndexPath*)cellIndex;

@end
