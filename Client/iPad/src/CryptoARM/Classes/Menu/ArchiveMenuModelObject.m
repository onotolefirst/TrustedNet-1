//
//  ArchiveMenuModelObject.m
//  CryptoARM
//
//  Created by Денис Бурдин on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArchiveMenuModelObject.h"

@implementation ArchiveMenuModelObject
@synthesize title, creationDate, size, typeOrContent, isDirectory, fileExtension, strDocImagePath, fullFilePath;  

- (id)initWithFilePath:(NSString *)filePath
{
    self = [super init];
    if ( self )
    {
        NSArray *arrExtensions = [[filePath lastPathComponent] componentsSeparatedByString:@"."];        
        isDirectory = ([arrExtensions count] < 2) ? true : false;
            
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory])
        {
            // TODO:throw error
        }
        else
        {
            fullFilePath = [filePath copy];
            // set item name
            title = [[filePath lastPathComponent] copy];

            // set language from CryptoARM settings panel
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSArray  *languages = [defaults objectForKey:@"AppleLanguages"];
            NSString *selectedLanguage = [languages objectAtIndex:0];
            NSString *localeIdentifier;
            
            if ([selectedLanguage isEqualToString:@"ru"])
            {
                localeIdentifier = @"ru_RU";
            }
            else if ([selectedLanguage isEqualToString:@"en"])
            {
                localeIdentifier = @"en_EN";
            }
            
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
            
            // this converts the date to a string
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:locale];
            [dateFormatter setFormatterBehavior:NSDateFormatterBehaviorDefault];

            // extract from file its creation date
            NSFileManager* fm = [NSFileManager defaultManager];
            NSDictionary* attrs = [fm attributesOfItemAtPath:filePath error:nil];
            NSDate* fileCreationDate = [attrs objectForKey: NSFileCreationDate];
            
            // get the name of the month
            [dateFormatter setDateFormat:@"MMMM"];
            NSString *monthName = [dateFormatter stringFromDate:fileCreationDate];
            
            // extract date and year
            NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSYearCalendarUnit fromDate:fileCreationDate];
            
            // set creation date info
            creationDate = [[NSString stringWithFormat:@"%@: %d %@ %d %@.", NSLocalizedString(@"WIZARD_CREATED", @"WIZARD_CREATED"), [dateComponents day], monthName, [dateComponents year], NSLocalizedString(@"YEAR_PREFIX", @"YEAR_PREFIX")] copy];

            // extract from file all necessary information and number of embedded elements if it is directory
            if (isDirectory)
            {
                // get entire size of all content in this folder(including subfolders)
                size = [[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"WIZARD_SIZE", @"WIZARD_SIZE"), [Utils formattedFileSize:[Utils folderSize:filePath]]] copy];
                strDocImagePath = @"folder.png";

                // determine count of all files in the directory
                typeOrContent = [[NSMutableString alloc] init];
                [typeOrContent appendString:NSLocalizedString(@"CONTENT", @"CONTENT")];
                [typeOrContent appendString:@": "];                
                
                NSFileManager *localFileManager = [[NSFileManager alloc] init];
                NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:filePath];
                NSArray *arrAllObjects = [dirEnum allObjects];

                [typeOrContent appendString:[NSString stringWithFormat:@"%d ", [arrAllObjects count]]];
                [typeOrContent appendString:NSLocalizedString(@"ELEMENTS", @"ELEMENTS")];
            }
            else
            {
                // get the file size
                NSError *errorAttr;
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&errorAttr];

                size = [[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"WIZARD_SIZE", @"WIZARD_SIZE"), [Utils formattedFileSize:[[fileAttributes objectForKey:NSFileSize] intValue]]] copy];

                // determine type of the document by its extension
                NSArray *arrExtensions = [[filePath lastPathComponent] componentsSeparatedByString:@"."];
                NSString *strExtension = [arrExtensions objectAtIndex:([arrExtensions count] - 1)];

                typeOrContent = [[NSMutableString alloc] init];
                [typeOrContent appendString:NSLocalizedString(@"TYPE", @"TYPE")];
                [typeOrContent appendString:@": "];

                NSMutableString *strPath = [[NSMutableString alloc] init];
                [typeOrContent appendString:[Utils getFileTypeByExtension:strExtension outDocImageIconPath:strPath]];

                strDocImagePath = [strPath copy];
                [strPath release];
                fileExtension = strExtension;
            }
        }
    }

    return self;
}

- (void)dealloc
{
    [title release];
    [creationDate release];
    [size release];
    
    if (typeOrContent)
    {
        [typeOrContent release];
    }
    
    [fileExtension release];
    [strDocImagePath release];
    [fullFilePath release];
}

@end
