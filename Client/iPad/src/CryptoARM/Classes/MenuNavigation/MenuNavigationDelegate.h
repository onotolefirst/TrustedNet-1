//
//  MenuNavigationDelegate.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MenuNavigationDelegate <NSObject>

- (void)addItem:(CommonNavigationItem*)newItem forIndex:(NSIndexPath*)currentIndex;
- (void)showDetailController:(UIViewController<NavigationSource>*)subController;

@end
