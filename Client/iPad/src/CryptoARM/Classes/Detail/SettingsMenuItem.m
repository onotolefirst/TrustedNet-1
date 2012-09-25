//
//  SettingsMenuItem.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsMenuItem.h"

@implementation SettingsMenuItem

@synthesize title;
@synthesize action;
@synthesize target;

- (id)initWithTitle:(NSString*)itemTitle withAction:(SEL)itemAction forTarget:(id)actionTarget;
{
    self = [super init];
    if( self )
    {
        title = itemTitle;
        action = itemAction;
        target = actionTarget;
    }
    return self;
}

@end
