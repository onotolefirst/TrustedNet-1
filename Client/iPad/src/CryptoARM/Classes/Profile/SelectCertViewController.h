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
#import "CertificateStore.h"

enum ENM_SEL_CERT_PAGE_TYPE {
    SCPT_SIGN_CERT = 0,
    SCPT_ENCRYPT_CERT = 1,
    SCPT_RECIEVERS_CERTS = 2,
    SCPT_DECRYPT_CERT = 3,
    SCPT_VALIDATION_CERTS = 4
    };

enum ENM_SCOPE_VALUE_INDEX {
    SVI_SUBJECT = 0,
    SVI_ISSUER = 1,
    SVI_VALID_FROM = 2,
    SVI_VALID_TO = 3
    };

@interface SelectCertViewController : CommonDetailController <NavigationSource, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>
{
    enum ENM_SEL_CERT_PAGE_TYPE pageType;
    
    UIImage *checkedValid;
    UIImage *uncheckedValid;
    
    enum CERT_STORE_TYPE currentSelectedStoreType;
    
    BOOL isFiltered;
    UISearchDisplayController *searchController;
    

    //Dictionary for certificates arrays, readed from various storages
    NSMutableDictionary *storagesDictionary;
    //Dictionary for index maps of filtered certificates (used for filtering)
    NSMutableDictionary *filteredCertificatsMapsDictionary;
    //Dictionary of selected indexes for various storages (used for selecting multiple certificates)
    NSMutableDictionary *selectedCertificatesIndexesDictionary;
    
    SettingsMenuSource  *settingsMenu;
}

- (id)initWithProfile:(Profile *)profile andSelectType:(enum ENM_SEL_CERT_PAGE_TYPE)listType;

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, retain) Profile *parentProfile;

@property (nonatomic, retain) NSString *filterString;
@property NSInteger filterScope;

- (void)actionSaveEncRecievers;
- (void)actionSaveCertsForValidation;

- (void)selectStore:(enum CERT_STORE_TYPE)storeToSelect;

- (void)applyFiltering;

- (NSArray*)extendedKeyUsageFromCert:(X509*)x509Cert;

- (NSIndexSet*)storesAvailableForPageType:(enum ENM_SEL_CERT_PAGE_TYPE)listType;
- (enum CERT_STORE_TYPE)defaultStoreForPageType:(enum ENM_SEL_CERT_PAGE_TYPE)listType;

- (NSMutableArray*)currentSelectedStoreCertificates;
- (NSMutableDictionary*)currentStoreFilteringMap;
- (NSMutableIndexSet*)currentStoreSelectedCertsIndex;

- (void)actionSelectStoreMy;
- (void)actionSelectStoreAdressBook;
- (void)actionSelectStoreCa;
- (void)actionSelectStoreRoot;

- (void)constructSettingsMenu;

- (NSString*)storeNameByType:(enum CERT_STORE_TYPE)storeType;

@end
