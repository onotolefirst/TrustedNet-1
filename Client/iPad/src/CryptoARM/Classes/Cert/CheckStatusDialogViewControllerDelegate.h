//
//  CheckStatusDialogViewControllerDelegate.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 18.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CheckStatusDialogViewControllerDelegate <NSObject>

// Method for dismissing modal check status dialog and recieving verifying result
- (void)statusVerifying:(BOOL)notCancelled withParameters:(int)verifyingParameters;

@end
