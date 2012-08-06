//
//  ParametersPanel.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CommonDetailController.h"
//#import "CertUsageHelper.h"
#import "Profile.h"

#define DISPLAYING_PIN_LENGTH_MOD 9

enum EnmPageType {
    PT_SIGNING = 1,
    PT_ENCRYPTION = 2,
    PT_DECRYPTION = 3,
    PT_CERTPOLICY = 4,
    PT_ADDITIONAL_SIGN_PARAMS = 5
    };

@interface ParametersPanel : CommonDetailController <NavigationSource, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>
{
    UISwitch *switchEncryptToSender;
    UISwitch *switchDetachedSign;
    UISwitch *switchSignArchive;
    UISwitch *switchSignResourceIsFile;
    UISwitch *switchRemoveFileAfterEncryption;
    UISwitch *switchEncryptArchive;
    
    UITextField *pinField;
    UITextField *commentField;
    UITextField *resourceField;
    
    enum EnmPageType panelTypeIdValue;
}

@property enum EnmPageType panelTypeId;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) Profile *parentProfile;

@property BOOL editMode;

@property (nonatomic, retain) NSArray *signUsages;

- (id)initWithParentProfile:(Profile*)profileFromParent;
- (void)dealloc;

- (void)refreshTableData;
- (void)refreshTableSections:(NSIndexSet*)sectionsToReload;

// Actions
- (void)switchChangeAction;
- (void)switchDetachChangeAction;
- (void)switchSignArchiveChangeAction;
- (void)switchSignResourceisFileAction;
//- (void)switchRemoveFileAfterEncryption:(id)sender;
- (void)switchRemoveFileAfterEncryptionAction;
- (void)switchEncryptArchiveAction;

- (void)selectSignCertAction;
- (void)selectEncryptionCertAction;
- (void)selectRecieversCertsAction;
- (void)selectDecryptionCertAction;
- (void)selectCertsForValidationAction;
- (void)selectSigCertsFilter;
- (void)selectEncCertsFilter;

- (void)editSignPin:(id)sender;
- (void)editSignComment:(id)sender;
- (void)editSignResource:(id)sender;

@end
