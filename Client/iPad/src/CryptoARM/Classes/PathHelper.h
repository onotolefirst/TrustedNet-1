//
//  PathHelper.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define PATH_OPERATIONAL_SETTINGSs "/Settings"

#define FILENAME_CERTIFICATE_USAGESs "OidsDictionaryFile.xml"

@interface PathHelper : NSObject

+ (NSString*)getAppDir;
+ (NSString*)getAppDir:(NSError**)error;

+ (NSString*)getOperationalSettinsDirectoryName;
+ (NSString*)getOperationalSettinsDirectoryPath;
+ (NSString*)getOperationalSettinsDirectoryPath:(NSError**)error;

+ (NSString*)getCertUsagesFileName;
@end
