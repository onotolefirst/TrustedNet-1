//
//  MenuSource.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SettingsMenuSourceDelegate.h"

@interface SettingsMenuSource : NSObject <UITableViewDelegate, UITableViewDataSource>
{
    NSString *menuTitle;
    NSMutableArray *menuItemsArray;
    
    UIPopoverController *menuPopover;
}

@property (nonatomic, readonly) NSString *menuTitle;

- (id)initWithTitle:(NSString*)title;
- (void)dealloc;

- (void)addMenuItem:(NSString*)itemTitle withAction:(SEL)action forTarget:(id)target;
//- (void)addMenuItem:(NSString*)itemTitle withAction:(SEL)action forTarget:(id)target andImage:(UIImage*)itemImage;
//- (void)insertMenuItem:(NSUInteger)index ...;

@property (nonatomic, retain) UIPopoverController *menuPopover;
@property (nonatomic, retain) id<SettingsMenuSourceDelegate> delegate;

@end
