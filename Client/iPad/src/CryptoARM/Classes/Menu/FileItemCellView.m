//
//  FileItemCellView.m
//  CryptoARM
//
//  Created by Денис Бурдин on 17.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FileItemCellView.h"

@implementation FileItemCellView
@synthesize title, creationDate, size, typeOrContent, docImageView, btnTick, checked, fullFilePath;  

- (id)init
{
    self = [super init];
    if ( self )
    {
        checked = NO; // default is unchecked
    }

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];    
    // Configure the view for the selected state
}

- (void)dealloc
{
    [title release];
    [creationDate release];
    [size release];
    [docImageView release];
    [btnTick release];
    
    if (fullFilePath)
    {
        [fullFilePath release];
    }
}

@end
