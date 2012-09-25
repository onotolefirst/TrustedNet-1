//
//  StatisticsPanel.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StatElement.h"
#import "RefreshingProtocol.h"
#import "StatisticsHelper.h"


@interface StatisticsPanel : UIViewController <RefreshingProtocol> {
    
    StatElement *statCerts;
    StatElement *statCrls;
    StatElement *statRequests;
    StatElement *statUservoice;
    StatElement *statProfile;
    UIView *viewCerts;
    UIView *viewCrls;
    UIView *viewRequests;
    UIView *viewUservoice;
    UIView *viewProfile;
}

@property (nonatomic, retain) IBOutlet StatElement *statCerts;
@property (nonatomic, retain) IBOutlet StatElement *statCrls;
@property (nonatomic, retain) IBOutlet StatElement *statRequests;
@property (nonatomic, retain) IBOutlet StatElement *statUservoice;
@property (nonatomic, retain) IBOutlet StatElement *statProfile;
@property (nonatomic, retain) IBOutlet UIView *viewCerts;
@property (nonatomic, retain) IBOutlet UIView *viewCrls;
@property (nonatomic, retain) IBOutlet UIView *viewRequests;
@property (nonatomic, retain) IBOutlet UIView *viewUservoice;
@property (nonatomic, retain) IBOutlet UIView *viewProfile;

@property (nonatomic, retain) StatisticsHelper *statisticsHelper;

- (void)reloadData;

@end
