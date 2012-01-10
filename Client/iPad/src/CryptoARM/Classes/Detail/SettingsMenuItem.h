//
//  SettingsMenuItem.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsMenuItem : NSObject

- (id)initWithTitle:(NSString*)itemTitle withAction:(SEL)itemAction forTarget:(id)actionTarget;

@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) SEL action;
@property (nonatomic, readonly) id target;

@end
