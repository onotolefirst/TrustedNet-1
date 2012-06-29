//
//  ArchiveMenuModelContent.h
//  CryptoARM
//
//  Created by Денис Бурдин on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Utils.h"

@interface ArchiveMenuModelContent : UITableViewCell
{
    UILabel *title;
    UILabel *creationDate;
    UILabel *size;
    UILabel *typeOrContent;
    UIImageView *docImageView;
    UIButton *btnTick;
    NSString *fullFilePath;
    bool checked; // for multiple select certificates, should be changed only in user defined code
}

@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *creationDate;
@property (nonatomic, retain) IBOutlet UILabel *size;
@property (nonatomic, retain) IBOutlet UILabel *typeOrContent;
@property (nonatomic, retain) IBOutlet UIImageView *docImageView;
@property (nonatomic, retain) IBOutlet UIButton *btnTick;
@property (nonatomic, retain) NSString *fullFilePath;
@property (nonatomic, assign) bool checked;

@end

