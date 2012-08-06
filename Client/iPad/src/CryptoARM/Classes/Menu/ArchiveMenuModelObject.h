//
//  ArchiveMenuModelObject.h
//  CryptoARM
//
//  Created by Денис Бурдин on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Utils.h"

@interface ArchiveMenuModelObject : NSObject
{
    NSString *title;
    NSString *creationDate;
    NSString *size;
    NSMutableString *typeOrContent;
    BOOL isDirectory;
    NSString *fileExtension;
    NSString *strDocImagePath;
    NSString *fullFilePath; // each cell contains full file path to bound file
}

@property (nonatomic, retain) IBOutlet NSString *title;
@property (nonatomic, retain) IBOutlet NSString *fileExtension;
@property (nonatomic, retain) IBOutlet NSString *creationDate;
@property (nonatomic, retain) IBOutlet NSString *size;
@property (nonatomic, retain) IBOutlet NSMutableString *typeOrContent;
@property (nonatomic, retain) NSString *strDocImagePath;
@property (nonatomic, retain) NSString *fullFilePath;
@property (nonatomic, assign) BOOL isDirectory;

- (id)initWithFilePath:(NSString *)filePath;

@end

