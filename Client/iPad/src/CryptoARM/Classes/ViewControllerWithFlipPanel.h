//
//  ViewControllerWithFlipPanel.h
//  Test-flip-panel
//
//  Created by Sergey Mityukov on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewControllerWithFlipPanel : UIViewController {
    NSArray *viewControllersArray;
    NSInteger bottomPanelShare;
    
    UIView *controllerRootView;

    BOOL panelFlipped;
}

@property (nonatomic, retain) NSArray *viewControllers;
@property NSInteger bottomPanelShare;
@property BOOL panelFlipped;

- (id)initWithTopPanel:(UIViewController*)topPanel andBottomPanel:(UIViewController*)bottomPanel;
- (id)initWithTopPanel:(UIViewController*)topPanel bottomPanel:(UIViewController*)bottomPanel andCustomButton:(UIViewController*)customButton;
- (void)setFlippedState:(BOOL)flipped andPanelShare:(NSInteger)share withAnimation:(BOOL)animate;
- (void)setTitleForOpenedButton:(NSString*)openedTitle andClosedButton:(NSString*)closedTitle;

@end
