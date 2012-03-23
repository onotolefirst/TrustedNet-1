//
//  ProfileMenuModel.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileMenuModel.h"

#import "ProfileViewController.h"
#import "PathHelper.h"

@implementation ProfileMenuModel

- (id)init
{
    self = [super init];
    if(self)
    {
        profilesHelper = [[ProfileHelper alloc] initWithStorageFile:nil];
        filteredProfiles = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [filteredProfiles release];
    [profilesHelper release];
    
    [super dealloc];
}


#pragma mark - CommonNavigationItem methods overloading

- (NSString*)menuTitle
{
    return NSLocalizedString(@"PROFILES_TITLE", @"Операционные настройки");
}

- (NSInteger)mainMenuSections
{
    return 1;
}

- (NSInteger)mainMenuRowsInSection:(NSInteger)section
{
    return (self.filtered ? filteredProfiles.count : profilesHelper.profiles.count);
}

- (UITableViewCellAccessoryType)typeOfElementAt:(NSIndexPath *)idx
{
    return UITableViewCellAccessoryDetailDisclosureButton;
}

- (UITableViewCell*)dequeOrCreateDefaultCell:(UITableView*)tableView
{
    static NSString *CellIdentifier = @"Profile cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    return cell;
}

- (UITableViewCell*)fillCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)idx inTableView:(UITableView*)tableView
{
    NSArray *currArray = (self.filtered ? filteredProfiles : profilesHelper.profiles);
    Profile *currentProfile = [currArray objectAtIndex:idx.row];
    cell.textLabel.text = currentProfile.name;
    cell.detailTextLabel.numberOfLines = 2;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Создана: %@\nОписание: %@", currentProfile.creationDateFormatted, currentProfile.description ? currentProfile.description : @""];
    
    cell.imageView.image = [UIImage imageNamed:@"profile.png"];
    
    return cell;
}

-(CommonNavigationItem*)submenuNavigationItemForIndex:(NSIndexPath*)indexPath
{
    return nil;
}

- (UIViewController<NavigationSource>*)getDetailControllerForElementAt:(NSIndexPath*)index
{
    return [[[ProfileViewController alloc] initWithProfile:[profilesHelper.profiles objectAtIndex:index.row]] autorelease];
}

- (CGFloat)cellHeight:(NSIndexPath *)indexPath
{
    return 64;
}

- (BOOL)showAddButton;
{
    return YES;
}

- (UIViewController<NavigationSource>*)createControllerForNewElement
{
    Profile *newProfile = [[Profile alloc] initEmpty];
    ProfileViewController *profileView = [[ProfileViewController alloc] initWithProfile:newProfile];
    profileView.editMode = YES;
    [newProfile release];
    return [profileView autorelease];
}

- (BOOL)filterable
{
    return YES;
}

- (NSArray*)dataScopes
{
    NSString *nameScope = NSLocalizedString(@"PROFILE_SCOPE_NAME", "@Название");
    NSString *descriptionScope = NSLocalizedString(@"PROFILE_SCOPE_DESCRIPTION", "@Описание");
    NSString *createdateScope = NSLocalizedString(@"PROFILE_SCOPE_CREATION_DATE", "@Дата создания");

    return [NSArray arrayWithObjects:nameScope, descriptionScope, createdateScope, nil];
}

- (void)applyFilterForSeachText:(NSString*)searchString andScope:(NSInteger)searchScope
{
    [filteredProfiles removeAllObjects];
    
    NSRange foundRange = {0};
    for (Profile *currentProfile in profilesHelper.profiles) {
        foundRange.location = NSNotFound;
        
        switch (searchScope) {
            case 0: //by name
                foundRange = [currentProfile.name rangeOfString:searchString];
                break;
                
            case 1: //by description
                foundRange = [currentProfile.description rangeOfString:searchString];
                break;
                
            case 2: //by date
                foundRange = [currentProfile.creationDateFormatted rangeOfString:searchString];
                break;
                
            default:
                foundRange.location = NSNotFound;
                break;
        }
        
        if( foundRange.location != NSNotFound )
        {
            [filteredProfiles addObject:currentProfile];
        }
    }
}

#pragma mark - MenuDataRefreshingProtocol support

- (void)addElement:(id)newElement
{
    Profile *newProfile = (Profile*)newElement;
    
    if( ![profilesHelper addProfile:newProfile] )
    {
        NSLog(@"Warning: unable to add profile");
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@/%@", [PathHelper getOperationalSettinsDirectoryPath], [PathHelper getProfilesFileName]];
    [profilesHelper writeStorage:fileName];
}

- (void)removeElement:(id)removingElement
{
    Profile *removingProfile = (Profile*)removingElement;
    [profilesHelper removeProfileWithId:removingProfile.profileId];
    
    NSString *fileName = [NSString stringWithFormat:@"%@/%@", [PathHelper getOperationalSettinsDirectoryPath], [PathHelper getProfilesFileName]];
    [profilesHelper writeStorage:fileName];
}

- (void)saveExistingElement:(id)savingElement
{
    Profile *savingProfile = (Profile*)savingElement;
    NSUInteger objIndex = -1;
    for (Profile *curProfile in profilesHelper.profiles) {
        if( [savingProfile.profileId compare:curProfile.profileId] == NSOrderedSame )
        {
            objIndex = [profilesHelper.profiles indexOfObject:curProfile];
        }
    }
    
    if( objIndex != -1 )
    {
        [profilesHelper.profiles replaceObjectAtIndex:objIndex withObject:savingProfile];
    }
    else
    {
        [profilesHelper.profiles addObject:savingProfile];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@/%@", [PathHelper getOperationalSettinsDirectoryPath], [PathHelper getProfilesFileName]];
    [profilesHelper writeStorage:fileName];
}

- (BOOL)checkIfExisting:(id)checkingElement
{
    Profile *examingProfile = (Profile*)checkingElement;
    return [profilesHelper checkIfExistsProfileWithId:examingProfile.profileId];
}

#pragma  mark - Reading and writing storage

//- (void)

@end
