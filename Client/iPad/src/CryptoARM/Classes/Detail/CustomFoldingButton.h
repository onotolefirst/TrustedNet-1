//
//  CustomFoldingButton.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomFoldingButton : UIViewController {
    UIToolbar *buttonsBar;
    UIBarButtonItem *panelTitle;
    UIBarButtonItem *progressItem;
    UIActivityIndicatorView *activityIndicator;
    
    NSArray *panelsForRefresh;
    NSThread *refreshingThread;
}

@property (nonatomic, retain) IBOutlet UIToolbar *buttonsBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *panelTitle;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *progressItem;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, retain) NSArray *panelsForRefresh;

- (void)flipHandler:(id)sender;
- (void)refreshInfo;

- (IBAction)flipAction:(id)sender;
- (IBAction)refreshAction:(id)sender;

@end
