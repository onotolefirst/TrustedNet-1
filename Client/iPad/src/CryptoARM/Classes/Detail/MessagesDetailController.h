//
//  MessagesDetailController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RefreshingProtocol.h"
#import "MessagesHelper.h"


@interface MessagesDetailController : UITableViewController <RefreshingProtocol> {
    MessagesHelper *msgHelper;
}

@end
