//
//  MainSplitViewController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailNavController.h"
#import "ArchiveMenuModel.h"

@interface MainSplitViewController : UISplitViewController {
    ArchiveMenuModel *archiveMenuModelController;
}

@property(nonatomic, retain) ArchiveMenuModel *archiveMenuModelController;

-(void)setDetailViewController:(UIViewController<NavigationSource>*)subViewController;

@end
