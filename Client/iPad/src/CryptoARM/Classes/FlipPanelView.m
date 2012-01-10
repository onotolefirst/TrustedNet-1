//
//  FlipPanelView.m
//  Test-flip-panel
//
//  Created by Sergey Mityukov on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipPanelView.h"


@implementation FlipPanelView

- (void)calculateRects:(struct RECTS *)currentRect
{
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    CGFloat topHeight = height*((CGFloat)(100-bottomPanelShare)/100);
    CGFloat bottomheight = height-topHeight-BUTTON_HEIGHT;
    
    currentRect->topRectOpened = CGRectMake(0, 0, width, topHeight);
    currentRect->bottomRectOpened = CGRectMake(0, topHeight+BUTTON_HEIGHT, width, bottomheight);
    currentRect->buttonRectOpened = CGRectMake(0, topHeight, width, BUTTON_HEIGHT);
    currentRect->topRectClosed = CGRectMake(0, 0, width, height-BUTTON_HEIGHT);
    currentRect->bottomRectClosed = CGRectMake(0, height, width, 60);
    currentRect->buttonRectClosed = CGRectMake(0, height-BUTTON_HEIGHT, width, BUTTON_HEIGHT);
    
    currentRect->rectsDefined = TRUE;
}

-(void)setFrames:(BOOL)animated
{
    if( [self.subviews count] < 4 )
    {
        return;
    }
    
    if( !(calculatedRects.rectsDefined) )
    {
        [self calculateRects:&calculatedRects];
    }
    
    NSTimeInterval animDuration = animated ? DEFAULT_ANIM_DURATION : 0;
    
    UIView *topView = [self.subviews objectAtIndex:1];
    UIView *bottomView = [self.subviews objectAtIndex:2];
    
    if(panelFlipped)
    {
        [UIView animateWithDuration:animDuration animations:^{
            topView.frame = calculatedRects.topRectOpened;
            bottomView.frame = calculatedRects.bottomRectOpened;
            buttonView.frame = calculatedRects.buttonRectOpened;
        }];
    }
    else
    {
        [UIView animateWithDuration:animDuration animations:^{
            topView.frame = calculatedRects.topRectClosed;
            bottomView.frame = calculatedRects.bottomRectClosed;
            buttonView.frame = calculatedRects.buttonRectClosed;
        }];
    }
    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        bottomPanelShare = DEFAULT_BOTTOM_PANEL_SHARE;
        calculatedRects.rectsDefined = FALSE;
        buttonPressed = FALSE;
        
        flipButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [flipButton setTitle:(panelFlipped ? buttonTitleOpened : buttonTitleClosed) forState:UIControlStateNormal];
        [flipButton addTarget:self action:@selector(buttonPressAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        [self setFrames:NO];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

-(BOOL)panelFlipped
{
    return panelFlipped;
}

-(void)setPanelFlipped:(BOOL)flipped
{
    panelFlipped = flipped;
    [self setFrames:NO];
}

- (NSInteger)bottomPanelShare
{
    return bottomPanelShare;
}

-(void)setBottomPanelShare:(NSInteger)share
{
    bottomPanelShare = share;
    calculatedRects.rectsDefined = FALSE;
    [self setFrames:NO];
}

- (void)layoutSubviews
{
    calculatedRects.rectsDefined = buttonPressed;
    buttonPressed = FALSE;
    [self setFrames:YES];
}

- (void)buttonPressAction:(id)sender
{
    panelFlipped = !panelFlipped;
    buttonPressed = TRUE;
    [self setFrames:YES];
}

- (void)setTopSubview:(UIView*)top bottomSubview:(UIView*)bottom andButtonSubview:(UIView*)button
{
    while( [self.subviews count] )
    {
        [[self.subviews objectAtIndex:0] removeFromSuperview];
    }
    
    buttonView = button ? button : flipButton;
    
    //TODO: make image defineable?
    UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"512-CryptoARM-logo.png"]];
    
    CGFloat newY = (self.bounds.size.height - self.bounds.size.width)/2, newHeight = self.bounds.size.width;
    backImage.frame = CGRectMake(self.bounds.origin.x, newY, self.bounds.size.width, newHeight);
    
    backImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    backImage.alpha = 0.05;
    
    [self addSubview:backImage];
    [self addSubview:top];
    [self addSubview:bottom];
    [self addSubview:buttonView];
    
    [backImage release];
}

- (void)setTitleForOpenedButton:(NSString*)openedTitle andClosedButton:(NSString*)closedTitle
{
    //TODO: set titles not only for standart button
    buttonTitleOpened = openedTitle;
    buttonTitleClosed = closedTitle;
    
    [flipButton setTitle:(panelFlipped ? buttonTitleOpened : buttonTitleClosed) forState:UIControlStateNormal];
}

//TODO: drag?

- (void)setFlippedState:(BOOL)flipped andPanelShare:(NSInteger)share withAnimation:(BOOL)animate
{
    panelFlipped = flipped;
    bottomPanelShare = share;
    calculatedRects.rectsDefined = FALSE;
    [self setFrames:animate];
}

@end
