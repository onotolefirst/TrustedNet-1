//
//  SystemSettingsMenuCellContent.m
//  CryptoARM
//
//  Created by Денис Бурдин on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SystemSettingsMenuCellContent.h"

@implementation SystemSettingsMenuCellContent

@synthesize title, creationDate, owner;  

- (id)initWithTitle:(NSString*)itemTitle andCreationDate:(NSString *)strCreationDate andOwner:(NSString *)strOwner
{
    self = [super init];
    if ( self )
    {
        title = itemTitle;
        creationDate = strCreationDate;
        owner = strOwner;
    }
    
    return self;
}

- (void)dealloc
{
    [title release];
    [creationDate release];
    [owner release];
}

@end
