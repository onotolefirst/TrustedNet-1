//
//  MenuDataRefreshinProtocol.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MenuDataRefreshinProtocol <NSObject>

- (void)addElement:(id)newElement;
- (void)removeElement:(id)removingElement;
- (void)saveExistingElement:(id)savingElement;

- (BOOL)checkIfExisting:(id)checkingElement;

@end
