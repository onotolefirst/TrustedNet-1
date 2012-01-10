//
//  StatisticsHelper.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StatisticsHelper : NSObject {

}

//TODO: define appropriate initializing
- (id)InitWithSomething;
- (void)refreshData;

- (NSInteger)validCerts;
- (NSInteger)invalidCerts;
- (NSInteger)validCrls;
- (NSInteger)invalidCrls;
- (NSInteger)processedRequests;
- (NSInteger)pendingRequests;
- (NSInteger)processedIdeas;
- (NSInteger)pendingIdeas;
- (NSString*)profileName;
- (NSString*)profileOwner;

@end
