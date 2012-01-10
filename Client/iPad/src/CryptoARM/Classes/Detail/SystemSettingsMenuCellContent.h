//
//  SystemSettingsMenuCellContent.h
//  CryptoARM
//
//  Created by Денис Бурдин on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemSettingsMenuCellContent : NSObject
{
    NSString *title;
    NSString *creationDate;
    NSString *owner;    
}

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *creationDate;
@property(nonatomic, retain) NSString *owner;

- (id)initWithTitle:(NSString*)itemTitle andCreationDate:(NSString *)strCreationDate andOwner:(NSString *)strOwner;

@end
