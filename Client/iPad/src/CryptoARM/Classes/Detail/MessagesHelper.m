//
//  MessagesHelper.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessagesHelper.h"

@implementation ApplicationMessage

@synthesize criticalLevel;
@synthesize message;
@synthesize actionId;

- (id)initWithLevel:(enum CRITICAL_LEVEL)level messageText:(NSString *)messageText andActionId:(NSInteger)action
{
    self = [super init];
    if(self)
    {
        criticalLevel = level;
        message = messageText;
        actionId = action;
    }
    return self;
}

@end

@implementation MessagesHelper
@synthesize messages;
@synthesize needToRefresh;

- (id)initWithSomething
{
    self = [super init];
    
    if( self )
    {
        needToRefresh = FALSE;
        [self refreshData];
    }
    
    return self;
}

- (void)refreshData
{
    ApplicationMessage *msg1 = [[ApplicationMessage alloc] initWithLevel:cl_high messageText:@"Very critical message" andActionId:0];
    ApplicationMessage *msg2 = [[ApplicationMessage alloc] initWithLevel:cl_middle messageText:@"Not so critical..." andActionId:0];
    ApplicationMessage *msg3 = [[ApplicationMessage alloc] initWithLevel:cl_low messageText:@"Normal message" andActionId:0];
    ApplicationMessage *msg4 = [[ApplicationMessage alloc] initWithLevel:cl_bell messageText:@"Some notification" andActionId:0];
    
    if( rand()%2 )
    {
        self.messages = [NSArray arrayWithObjects:msg1, msg2, msg3, msg4, nil];
    }
    else
    {
        self.messages = [NSArray arrayWithObjects:msg1, msg2, msg4, nil];
    }
    
    needToRefresh = FALSE;
    
    [msg1 release];
    [msg2 release];
    [msg3 release];
    [msg4 release];
}

- (void)saveData
{
    
}

@end
