//
//  SelectCertViewController.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Profile.h"
#import "CommonDetailController.h"

enum ENM_SEL_CERT_PAGE_TYPE {
    SCPT_SIGN_CERT = 0,
    SCPT_ENCRYPT_CERT = 1,
    SCPT_RECIEVERS_CERTS = 2,
    SCPT_DECRYPT_CERT = 3,
    SCPT_VALIDATION_CERTS = 4
    };

enum  ENM_STORE_TYPE {
    ST_PERSONAL = 0,
    ST_ROOT = 1,
    //...
    
    ST_DEFAULT = ST_PERSONAL
    };

enum ENM_SCOPE_VALUE_INDEX {
    SVI_SUBJECT = 0,
    SVI_ISSUER = 1,
    SVI_VALID_FROM = 2,
    SVI_VALID_TO = 3
    };

@interface SelectCertViewController : CommonDetailController <NavigationSource, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>
{
    //TODO: make certificate collection object and replace goddamn STACK structure
    STACK_OF(X509) *availableCertificates;
    enum ENM_SEL_CERT_PAGE_TYPE pageType;
    
    UIImage *checkedValid;
    UIImage *uncheckedValid;
    
    NSMutableIndexSet *personalStorageIndex;
    
    enum ENM_STORE_TYPE currentSelectedStoreType;
    
    BOOL isFiltered;
    UISearchDisplayController *searchController;
}

- (id)initWithProfile:(Profile *)profile andSelectType:(enum ENM_SEL_CERT_PAGE_TYPE)listType;

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, retain) Profile *parentProfile;
@property (nonatomic, retain) NSDictionary *filteredCertificatesMap;

@property (nonatomic, retain) NSString *filterString;
@property NSInteger filterScope;

- (void)actionSaveEncRecievers;
- (void)actionSaveCertsForValidation;

- (void)selectStore:(enum ENM_STORE_TYPE)storeToSelect;

- (void)applyFiltering;

- (NSArray*)extendedKeyUsageFromCert:(X509*)x509Cert;

@end
