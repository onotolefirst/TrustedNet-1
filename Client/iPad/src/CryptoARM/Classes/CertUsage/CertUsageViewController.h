//
//  CertUsageViewController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CertUsage.h"
#import "CommonDetailController.h"
#import "SaveDelButtonsPanelController.h"

@interface CertUsageViewController : CommonDetailController <NavigationSource>
{
    CertUsage* usage;
    
    NSString *titleForId;
    NSString *titleForDescription;
    
    SaveDelButtonsPanelController *buttonsBar;
}

- (id)initWithUsage:(CertUsage*)certUsage idLabel:(NSString*)labelId descriptionLabel:(NSString*) labelDescr;

@property (retain, nonatomic) CertUsage* usage;
@property (retain, nonatomic) IBOutlet UIImageView *usageImage;
@property (retain, nonatomic) IBOutlet UILabel *idLabel;
@property (retain, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (retain, nonatomic) IBOutlet UITextField *idField;
@property (retain, nonatomic) IBOutlet UITextField *descriptionField;

- (BOOL)buttonDelete:(id)sender;
- (BOOL)buttonSave:(id)sender;

@end
