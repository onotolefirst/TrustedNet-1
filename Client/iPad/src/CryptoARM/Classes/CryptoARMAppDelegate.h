//
//  CryptoARMAppDelegate.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MainSplitViewController.h"
#import "MenuNavigationController.h"
#import "Wizard/WizardEncryptViewController.h"
#import "ArchiveMenuModel.h"
#import "MenuListController.h"

@interface CryptoARMAppDelegate : NSObject <UIApplicationDelegate> {
    MainSplitViewController *mainController;
    WizardEncryptViewController *wizardEncryptController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, assign) WizardEncryptViewController *wizardEncryptController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
