//
//  ProfileMenuModel.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommonNavigationItem.h"
#import "MenuDataRefreshinProtocol.h"
#import "ProfileHelper.h"

@interface ProfileMenuModel : CommonNavigationItem <MenuDataRefreshinProtocol>
{
    ProfileHelper *profilesHelper;
    NSMutableArray *filteredProfiles;
}

- (id)init;

@end
