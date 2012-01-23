//
//  PathHelper.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PathHelper.h"

@implementation PathHelper

+ (NSString*)getAppDir
{
    return [PathHelper getAppDir:nil];
}

+ (NSString*)getAppDir:(NSError**)error;
{
    NSError *internalErrorPointer = nil;
    NSError **directoryError = (error ? error : &internalErrorPointer);
    
    //TODO: validate if this check is appropriate
    NSUInteger domain = [[UIDevice currentDevice].model compare:@"iPad Simulator"]==NSOrderedSame ? NSLocalDomainMask : NSUserDomainMask;
    NSURL *libraryUrl = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory inDomain:domain appropriateForURL:nil create:YES error:directoryError];
    if( *directoryError )
    {
        NSLog(@"error recieving library directory:\n\t%@", *directoryError);
        return @"";
    }
    
    return libraryUrl.path;
}

+ (NSString*)getOperationalSettinsDirectoryName
{
    return [NSString stringWithFormat:@"%s", PATH_OPERATIONAL_SETTINGSs];
}

+ (NSString*)getOperationalSettinsDirectoryPath
{
    return [PathHelper getOperationalSettinsDirectoryPath:nil];
}

+ (NSString*)getOperationalSettinsDirectoryPath:(NSError**)error
{
    NSLog(@"Recieved path:\n\t%@", [NSString stringWithFormat:@"%@%s", [PathHelper getAppDir:error], PATH_OPERATIONAL_SETTINGSs]);
    return [NSString stringWithFormat:@"%@%s", [PathHelper getAppDir:error], PATH_OPERATIONAL_SETTINGSs];
}

+ (NSString*)getCertUsagesFileName
{
    return [NSString stringWithFormat:@"%s", FILENAME_CERTIFICATE_USAGESs];
}

@end
