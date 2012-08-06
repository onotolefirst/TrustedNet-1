//
//  StatisticsHelper.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatisticsHelper.h"


@implementation StatisticsHelper

- (id)initWithSomething
{
    self = [super init];
    if( self )
    {
        //...
    }
    return self;
}

- (void)refreshData
{
    //...
}

- (NSInteger)validCerts
{
    return rand();
}

- (NSInteger)invalidCerts
{
    return rand();
}

- (NSInteger)validCrls
{
    return rand();
}

- (NSInteger)invalidCrls
{
    return rand();
}

- (NSInteger)processedRequests
{
    return rand();
}

- (NSInteger)pendingRequests
{
    return rand();
}

- (NSInteger)processedIdeas
{
    return rand();
}

- (NSInteger)pendingIdeas
{
    return rand();
}

- (NSString*)profileName
{
    return @"My profile";
}

- (NSString*)profileOwner
{
    return @"Владелец сертификата";
}


@end
