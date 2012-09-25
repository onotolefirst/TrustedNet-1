//
//  FlipPanelView.h
//  Test-flip-panel
//
//  Created by Sergey Mityukov on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#define DEFAULT_BOTTOM_PANEL_SHARE 33
#define BUTTON_HEIGHT 44
#define FLIP_DEFAULT_STATE YES
#define DEFAULT_ANIM_DURATION 0.3

struct RECTS {
    BOOL rectsDefined;
    CGRect topRectOpened, bottomRectOpened, buttonRectOpened, topRectClosed, bottomRectClosed, buttonRectClosed;
};


@interface FlipPanelView : UIView {
    struct RECTS calculatedRects;
    
    BOOL panelFlipped;
    NSInteger bottomPanelShare;
    
    UIButton *flipButton;
    UIView *buttonView;
    BOOL buttonPressed;
    
    NSString *buttonTitleOpened;
    NSString *buttonTitleClosed;
}

@property BOOL panelFlipped;
@property NSInteger bottomPanelShare;

- (void)setTopSubview:(UIView*)top bottomSubview:(UIView*)bottom andButtonSubview:(UIView*)button;
- (void)setTitleForOpenedButton:(NSString*)openedTitle andClosedButton:(NSString*)closedTitle;
- (void)setFlippedState:(BOOL)flipped andPanelShare:(NSInteger)share withAnimation:(BOOL)animate;

- (void)buttonPressAction:(id)sender;

@end
