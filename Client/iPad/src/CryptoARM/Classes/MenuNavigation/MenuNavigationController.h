//
//  MenuNavigationController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuNavigationController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UINavigationBar *navBar;
    UITableView *tableMenu;
}

@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UITableView *tableMenu;

- (id)initWithTable:(UITableView*)tblView andNavigationBar:(UINavigationBar*)navigationBar;

- (void)back:(id)sender;
- (void)returnToSection:(id)sender;
- (void)addButtonAction:(id)sender;

- (void)reloadMenuData;

@end
