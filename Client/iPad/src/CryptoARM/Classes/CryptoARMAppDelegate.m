//
//  CryptoARMAppDelegate.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CryptoARMAppDelegate.h"

#import "PathHelper.h"

@implementation CryptoARMAppDelegate

/* selected language for the application preference in our Settings.bundle */
NSString *kSelectedLanguage = @"application_language";

@synthesize window=_window;

@synthesize managedObjectContext=__managedObjectContext;

@synthesize managedObjectModel=__managedObjectModel;

@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;
@synthesize wizardEncryptController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    
    //init OpenSSL
    CRYPTO_malloc_init();
    ERR_load_crypto_strings();
    OpenSSL_add_all_algorithms();
    ENGINE_load_builtin_engines();

//    // Uncomment for full logging from engine
//    // Works only with debug libraries
//    LOG_set_level(LL_ALL);

    
    
    //  checking for application operational settings directory existence
    NSError *directoryError = nil;
    NSString *directoryPath = [PathHelper getOperationalSettinsDirectoryPath:&directoryError];
    if( directoryError )
    {
        NSLog(@"error recieving library directory:\n\t%@", directoryError);
    }
    else
    {
        NSError *checkError = nil;
        
        BOOL fileIsDirectory = YES;
        if( ![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&fileIsDirectory] )
        {
            NSDictionary *attrubutes = [NSDictionary dictionaryWithObject:[NSNumber numberWithLong:448] forKey:NSFilePosixPermissions];
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:attrubutes error:&checkError];
        }
        
        if( checkError )
        {
            NSLog(@"Error: Unable create folder \"%@\" with error:\n\t%@", directoryPath, checkError);
        }
    }
    
    //NSLog(@"\nDevice name:\t%@\nDevice model:\t%@\nSystem version:\t%@\nSystem name:\t%@", [UIDevice currentDevice].name, [UIDevice currentDevice].model, [UIDevice currentDevice].systemVersion, [UIDevice currentDevice].systemName);
    
    mainController = [[MainSplitViewController alloc] init];
    [self.window addSubview:mainController.view];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
   /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *keyValueStr = [defaults stringForKey:kSelectedLanguage];
    NSMutableArray* languages = [defaults objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    
    if (([keyValueStr isEqualToString:@"lng_eng"]) && (![preferredLang isEqualToString:@"en"]))
    {
        [languages replaceObjectAtIndex:0 withObject:@"en"];
        [defaults setValue:languages forKey:@"AppleLanguages"];
    }
    else if (([keyValueStr isEqualToString:@"lng_rus"]) && ((![preferredLang isEqualToString:@"ru"])))
    {
        [languages replaceObjectAtIndex:0 withObject:@"ru"];
        [defaults setValue:languages forKey:@"AppleLanguages"];
    }

    [defaults synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)dealloc
{
    [mainController.view removeFromSuperview];
    [mainController release];
    
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [wizardEncryptController release];
    
    [super dealloc];
}

- (void)awakeFromNib
{
    /*
     Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
    */
}

- (void)saveContext
{
    NSError *error = nil;
    if (self.managedObjectContext != nil)
    {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CryptoARM" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CryptoARM.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    // this function is called when we open any document(file) in CryptoARM("Open In..." operation)
    // release mainController
    if (mainController != nil)
    {
        [mainController.view removeFromSuperview];
        [mainController release];
    }

    mainController = [[MainSplitViewController alloc] init];
    [self.window addSubview:mainController.view];
 
    NSString *URLString = [url absoluteString];

    // %20 - space, need to be replaced
    URLString = [URLString stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    NSArray *arrUrlComponents = [URLString componentsSeparatedByString:@"/"];
    NSString *strID = [[[NSString alloc] init] autorelease];
    
    NSRange subStrRange = [[arrUrlComponents objectAtIndex:0] rangeOfString:@"cryptoarm"]; // this is the prefix for the application
    if (subStrRange.location != NSNotFound)
    {
        for (int i = 1; i < [arrUrlComponents count]; i++)
        {
            if ([[arrUrlComponents objectAtIndex:i] isEqualToString:@"certificate"])
            {
                // certificate prefix was found in the recieved url string
                strID = [arrUrlComponents objectAtIndex:i+1];
                break;
            }
        }
    }
    
    if ([strID length])
    {
        // TODO: transfer it into certificate detail page view
    }
    
    [self.window makeKeyAndVisible];
    wizardEncryptController = [[WizardEncryptViewController alloc] initWithNibName:@"WizardEncryptViewController" withFileURL:url bundle:nil];
    [mainController setDetailViewController:wizardEncryptController];
    
    return YES;
}

@end
