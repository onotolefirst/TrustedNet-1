//
//  MainMenuModel.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonNavigationItem.h"


@interface MainMenuModel : CommonNavigationItem {
    NSIndexPath *selectedRowIndex;
}

@property (nonatomic, retain) NSIndexPath* selectedRowIndex;

@end
