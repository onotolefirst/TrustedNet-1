//
//  KeyboardPositionDelegate.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KeyboardPositionDelegate <NSObject>

- (CGRect)getKeyboardPosition;

@end
