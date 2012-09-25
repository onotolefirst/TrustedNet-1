//
//  MessagesHelper.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum CRITICAL_LEVEL {
    cl_bell = 0,
    cl_low = 1,
    cl_middle = 2,
    cl_high = 3
    };

@interface ApplicationMessage : NSObject {
    enum CRITICAL_LEVEL criticalLevel;
    NSString* message;
    NSInteger actionId;
}
@property enum CRITICAL_LEVEL criticalLevel;
@property (nonatomic, retain) NSString* message;
@property NSInteger actionId;

-(id)initWithLevel:(enum CRITICAL_LEVEL)level messageText:(NSString*)messageText andActionId:(NSInteger)action;

@end

@interface MessagesHelper : NSObject {
    NSArray* messages;
    BOOL needToRefresh;
}

@property (nonatomic, retain) NSArray *messages;
@property BOOL needToRefresh;

//TODO: rename method
- (id)initWithSomething;
- (void)refreshData;
- (void)saveData;

@end
