//
//  SelectCertViewController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectCertViewController.h"

#import "Crypto.h"
#import "RecipientCertificateCellView.h"

@implementation SelectCertViewController

@synthesize parentProfile;
@synthesize filterString;
@synthesize filterScope;

- (id)initWithProfile:(Profile *)profile andSelectType:(enum ENM_SEL_CERT_PAGE_TYPE)listType;
{
    self = [super init];
    if(self)
    {
        self.parentProfile = profile;
        pageType = listType;
        currentSelectedStoreType = CST_MY;
        
        isFiltered = NO;
        self.filterScope = 0;
        self.filterString = @"";
        
        if( (SCPT_RECIEVERS_CERTS == pageType) || (SCPT_VALIDATION_CERTS == pageType) )
        {
            indexedImages = [[NSMutableDictionary alloc] initWithCapacity:2];
            
            {
                //TODO: add appropriate images for certificates
                UIImage *tmpImage = [Utils constructImageWithIcon:[UIImage imageNamed:@"cert-valid.png"] andAccessoryIcon:[UIImage imageNamed:@"checked.PNG"]];
                [indexedImages setObject:tmpImage forKey:[NSNumber numberWithInt:(IF_VALID | IF_CHECKED)]];
                
                tmpImage = [Utils constructImageWithIcon:[UIImage imageNamed:@"cert-valid.png"] andAccessoryIcon:[UIImage imageNamed:@"unchecked.PNG"]];
                [indexedImages setObject:tmpImage forKey:[NSNumber numberWithInt:IF_VALID]];
                
                
                tmpImage = [Utils constructImageWithIcon:[UIImage imageNamed:@"cert-invalid.png"] andAccessoryIcon:[UIImage imageNamed:@"checked.PNG"]];
                [indexedImages setObject:tmpImage forKey:[NSNumber numberWithInt:(IF_INVALID | IF_CHECKED)]];
                
                tmpImage = [Utils constructImageWithIcon:[UIImage imageNamed:@"cert-invalid.png"] andAccessoryIcon:[UIImage imageNamed:@"unchecked.PNG"]];
                [indexedImages setObject:tmpImage forKey:[NSNumber numberWithInt:IF_INVALID]];
                
                
                tmpImage = [Utils constructImageWithIcon:[UIImage imageNamed:@"cert-invalid.png"] andAccessoryIcon:[UIImage imageNamed:@"checked.PNG"]];
                [indexedImages setObject:tmpImage forKey:[NSNumber numberWithInt:(IF_UNKNOWN | IF_CHECKED)]];
                
                tmpImage = [Utils constructImageWithIcon:[UIImage imageNamed:@"cert-invalid.png"] andAccessoryIcon:[UIImage imageNamed:@"unchecked.PNG"]];
                [indexedImages setObject:tmpImage forKey:[NSNumber numberWithInt:IF_UNKNOWN]];
            }
            
            NSMutableArray *certsFromProfile;
            if( SCPT_RECIEVERS_CERTS == pageType)
            {
                certsFromProfile = [[NSMutableArray alloc] initWithArray:self.parentProfile.recieversCertificates];
            }
            else if( SCPT_VALIDATION_CERTS )
            {
                certsFromProfile = [[NSMutableArray alloc] initWithArray:self.parentProfile.certsForCrlValidation];
            }
            
            NSIndexSet *availableStorages = [self storesAvailableForPageType:pageType];
            [availableStorages enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [self selectStore:idx];
                
                //enumerate certs in profile
                NSMutableIndexSet *foundProfileCertsIndex = [[NSMutableIndexSet alloc] init];
                
                NSArray *availableCertificates = [self currentSelectedStoreCertificates];
                NSMutableIndexSet *currentSelectionIndex = [self currentStoreSelectedCertsIndex];
                
                for (id currentProfileCertObject in certsFromProfile)
                {
                    for( int i = 0; i < availableCertificates.count; i++ )
                    {
                        //skip already founded certificates
                        if( [currentSelectionIndex containsIndex:(NSUInteger)i] )
                        {
                            continue;
                        }
                        
                        CertificateInfo *storageCert = [availableCertificates objectAtIndex:i];
                        if( SCPT_RECIEVERS_CERTS == pageType )
                        {
                            CertificateInfo* currentProfileCert = (CertificateInfo*)currentProfileCertObject;
                            
                            if( !X509_issuer_and_serial_cmp(currentProfileCert.x509, storageCert.x509) )
                            {
                                //if cert is match, remember it's index in store and index in profile array
                                [currentSelectionIndex addIndex:(NSInteger)i];
                                [foundProfileCertsIndex addIndex:[certsFromProfile indexOfObject:currentProfileCert]];
                                break;
                            }
                        }
                        else if( SCPT_VALIDATION_CERTS == pageType )
                        {
                            NSString *currentProfileCertIdString = (NSString*)currentProfileCertObject;
                            
                            if( [Profile isCertificate:storageCert correspondsToIdString:currentProfileCertIdString] )
                            {
                                //if cert is match, remember it's index in store and index in profile array
                                [currentSelectionIndex addIndex:(NSInteger)i];
                                [foundProfileCertsIndex addIndex:[certsFromProfile indexOfObject:currentProfileCertIdString]];
                                break;
                            }
                        }
                    }   
                }

                //remove already founded certs from array to enumerate smaller number of certs in next store
                [certsFromProfile removeObjectsAtIndexes:foundProfileCertsIndex];
                [foundProfileCertsIndex release];
            }];

            
            [certsFromProfile release];
        }
        
        [self constructSettingsMenu];
    }
    return self;
}

- (void)dealloc
{
    if( indexedImages )
    {
        [indexedImages release];
    }
    
    if( storagesDictionary )
    {
        [storagesDictionary release];
    }
    
    if( filteredCertificatsMapsDictionary )
    {
        [filteredCertificatsMapsDictionary release];
    }
    
    if( selectedCertificatesIndexesDictionary )
    {
        [selectedCertificatesIndexesDictionary release];
    }
    
    if( settingsMenu )
    {
        [settingsMenu release];
    }
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (UITableView*)tableView
{
    return (UITableView*)self.view;
}

#pragma mark - View lifecycle

- (void)loadView
{
    UITableView *mainTableView = [[UITableView alloc] init];
    self.view = mainTableView;
    [mainTableView release];
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;

    searchBar.frame = CGRectMake(0, -44, self.tableView.bounds.size.width, 44);
    searchBar.tintColor = [UIColor colorWithRed:(CGFloat)187/255 green:(CGFloat)2/255 blue:(CGFloat)4/255 alpha:1];
    searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"Владелец", @"Издатель", @"Действителен с", @"Действителен по", nil];
    
    self.tableView.tableHeaderView = searchBar;
    
    [searchBar release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self selectStore:[self defaultStoreForPageType:pageType]];
    
    self.tableView.contentOffset = CGPointMake(0,  44);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [searchController release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if( isFiltered )
    {
        return [self currentStoreFilteringMap].count;
    }
    
    return [self currentSelectedStoreCertificates].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectCertForProfileCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    CertificateInfo *currentCert = nil;
    NSNumber *certIndex = nil;
    NSArray *availableCertificates = [self currentSelectedStoreCertificates];
    if( isFiltered )
    {
        certIndex = [[self currentStoreFilteringMap] objectForKey:[NSNumber numberWithInt:indexPath.row]];
        if( certIndex )
        {
            currentCert = [[self currentSelectedStoreCertificates] objectAtIndex:certIndex.intValue];
        }
        else
        {
            NSLog(@"Error: index not found in map!");
        }
    }
    else
    {
        currentCert = [availableCertificates objectAtIndex:indexPath.row];
    }

    cell.textLabel.text = [Crypto getDNFromX509_NAME:currentCert.subject withNid:NID_commonName];
    cell.detailTextLabel.numberOfLines = 2;
    
    
    //-------------------------------------

    NSString *certExpirationDate = [Utils formatDateForCertificateView:[NSDate dateWithTimeIntervalSince1970:currentCert.validTo]];
    
    //-------------------------------------
    NSString *certIssuer = [Crypto getDNFromX509_NAME:currentCert.issuer withNid:NID_commonName];
    //-------------------------------------                               
    
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Кем выдан:%@\nИстекает: %@", certIssuer, certExpirationDate];
    
    switch (pageType) {
        case SCPT_SIGN_CERT:
        case SCPT_ENCRYPT_CERT:
            switch ([CertificateInfo simplifyedStatusByDetailedStatus:[currentCert verify]])
            {
                case CSS_VALID:
                    [cell.imageView setImage:[UIImage imageNamed:@"cert-valid.png"]];
                    break;
                    
                case CSS_INVALID:
                    [cell.imageView setImage:[UIImage imageNamed:@"cert-invalid.png"]];
                    break;
                    
                case CSS_INSUFFICIENT_INFO:
                default:
                    [cell.imageView setImage:[UIImage imageNamed:@"cert-invalid.png"]];
                    break;
            }
            break;
            
        case SCPT_RECIEVERS_CERTS:
        case SCPT_VALIDATION_CERTS:
        {
            //TODO: check certificate status and draw appropriate image
            int imageFlags = 0;
            NSUInteger mappedIndex = isFiltered ? certIndex.intValue : indexPath.row;
            if( [[self currentStoreSelectedCertsIndex] containsIndex:mappedIndex] )
            {
                imageFlags |= IF_CHECKED;
            }
            
            switch ([CertificateInfo simplifyedStatusByDetailedStatus:[currentCert verify]])
            {
                case CSS_VALID:
                    imageFlags |= IF_VALID;
                    break;
                    
                case CSS_INVALID:
                    imageFlags |= IF_INVALID;
                    break;
                    
                case CSS_INSUFFICIENT_INFO:
                default:
                    imageFlags |= IF_UNKNOWN;
                    break;
            }
            
            cell.imageView.image = [indexedImages objectForKey:[NSNumber numberWithInt:imageFlags]];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    CertificateInfo *selectedCert = nil;
    NSNumber *certIndex = nil;
    NSArray *availableCertificates = [self currentSelectedStoreCertificates];
    if( isFiltered )
    {
        certIndex = [[self currentStoreFilteringMap] objectForKey:[NSNumber numberWithInt:indexPath.row]];
        if( certIndex )
        {
            selectedCert = [availableCertificates objectAtIndex:certIndex.intValue];
        }
        else
        {
            NSLog(@"Error: index not found in map!");
        }
    }
    else
    {
        selectedCert = [availableCertificates objectAtIndex:indexPath.row];
    }
    
    
    switch (pageType) {
        case SCPT_SIGN_CERT:
        {
            self.parentProfile.signCertificate = selectedCert;
            [parentNavController.navCtrlr popViewControllerAnimated:YES];
        }
            break;
            
        case SCPT_ENCRYPT_CERT:
        {
            CertificateInfo *certToRemove = nil;
            if( self.parentProfile.encryptToSender && self.parentProfile.encryptCertificate )
            {
                for (CertificateInfo *currentCert in self.parentProfile.recieversCertificates) {
                    if( !X509_issuer_and_serial_cmp(currentCert.x509, self.parentProfile.encryptCertificate.x509) )
                    {
                        certToRemove = currentCert;
                    }
                }
            }
            
            self.parentProfile.encryptCertificate = selectedCert;
            
            if( self.parentProfile.encryptToSender )
            {
                NSMutableArray *tempArray = nil;
                tempArray = [NSMutableArray arrayWithArray:self.parentProfile.recieversCertificates];
                if( certToRemove )
                {
                    [tempArray removeObject:certToRemove];
                }
                [tempArray addObject:self.parentProfile.encryptCertificate];
                self.parentProfile.recieversCertificates = [NSArray arrayWithArray:tempArray];
            }
            
            [parentNavController.navCtrlr popViewControllerAnimated:YES];
        }
            break;
            
        case SCPT_RECIEVERS_CERTS:
        case SCPT_VALIDATION_CERTS:
        {
            NSUInteger selectedIndex = isFiltered ? certIndex.intValue : indexPath.row;
            
            if( [[self currentStoreSelectedCertsIndex] containsIndex:selectedIndex] )
            {
                [[self currentStoreSelectedCertsIndex] removeIndex:selectedIndex];
            }
            else
            {
                [[self currentStoreSelectedCertsIndex] addIndex:selectedIndex];
            }
            
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        case SCPT_DECRYPT_CERT:
        {
            self.parentProfile.decryptCertificate = selectedCert;
            [parentNavController.navCtrlr popViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self storeNameByType:currentSelectedStoreType];
}

#pragma mark - NavigationSource protocol support

+ (NSString*)itemTag
{
    return @"SelectCertViewController";
}

- (NSString*)itemTag
{
    return [SelectCertViewController itemTag];
}

- (NSString*)title
{
    switch (pageType) {
        case SCPT_SIGN_CERT:
            return NSLocalizedString(@"PROFILE_SEL_CERT_SIGNATURE_CERTIFICATE", @"Сертификат подписи");
            break;

        case SCPT_ENCRYPT_CERT:
            return NSLocalizedString(@"PROFILE_SEL_CERT_ENCRYPTION_CERTIFICATE", @"Сертификат шифрования");
            break;
            
        case SCPT_RECIEVERS_CERTS:
            return NSLocalizedString(@"PROFILE_SEL_CERT_RECIEVERS_CERTIFICATES", @"Сертификаты получателей");
            break;
            
        case SCPT_DECRYPT_CERT:
            return NSLocalizedString(@"PROFILE_SEL_CERT_DECRYPTING_CERTIFICATES", @"Сертификат расшифрования");
            break;
            
        case SCPT_VALIDATION_CERTS:
            return NSLocalizedString(@"PROFILE_SEL_CERT_CERTIFICATES_FOR_VALIDATION_BY_CRL", @"Сертификаты, требующие загрузки CRL из УЦ");
            break;
            
        default:
            break;
    }
    
    NSLog(@"Error: page type not specified");
    return @"ERROR: page type not specified";
}

- (SettingsMenuSource*)settingsMenu
{ 
    return settingsMenu;
}

- (void)constructSettingsMenu
{
    if( settingsMenu )
    {
        return;
    }
    
    settingsMenu = [[SettingsMenuSource alloc] initWithTitle:NSLocalizedString(@"Хранилища сертификатов", @"Хранилища сертификатов")];
    
    NSIndexSet *availableStorages = [self storesAvailableForPageType:pageType];
    if( [availableStorages containsIndex:CST_MY] )
    {
        [settingsMenu addMenuItem:[self storeNameByType:CST_MY] withAction:@selector(actionSelectStoreMy) forTarget:self];
    }
    
    if( [availableStorages containsIndex:CST_ADDRESS_BOOK] )
    {
        [settingsMenu addMenuItem:[self storeNameByType:CST_ADDRESS_BOOK] withAction:@selector(actionSelectStoreAdressBook) forTarget:self];
    }
    
    if( [availableStorages containsIndex:CST_CA] )
    {
        [settingsMenu addMenuItem:[self storeNameByType:CST_CA] withAction:@selector(actionSelectStoreCa) forTarget:self];
    }
    
    if( [availableStorages containsIndex:CST_ROOT] )
    {
        [settingsMenu addMenuItem:[self storeNameByType:CST_ROOT] withAction:@selector(actionSelectStoreRoot) forTarget:self];
    }
    
    settingsMenu.delegate = self;
}

- (NSArray*)getAdditionalButtons
{
    switch (pageType) {
//        case SCPT_SIGN_CERT:
//        {
//            return nil;
//        }
//            break;
            
//        case SCPT_ENCRYPT_CERT:
//        {
//            return nil;
//        }
//            break;
            
        case SCPT_RECIEVERS_CERTS:
        {
            return [NSArray arrayWithObject:[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BUTTON_DONE", @"Готово") style:UIBarButtonItemStyleBordered target:self action:@selector(actionSaveEncRecievers)] autorelease]];
        }
            break;
            
//        case SCPT_DECRYPT_CERT:
//        {
//            return nil;
//        }
//            break;
            
        case SCPT_VALIDATION_CERTS:
        {
            return [NSArray arrayWithObject:[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BUTTON_DONE", @"Готово") style:UIBarButtonItemStyleBordered target:self action:@selector(actionSaveCertsForValidation)] autorelease]];
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (void)setParentNavigationController:(UIViewController*)navController
{
    parentNavController = (DetailNavController*)navController;
}

- (BOOL)preserveController
{
    return FALSE;
}

- (Class)getSavingObjcetClass
{
    return [self class];
}

- (id<MenuDataRefreshinProtocol>)createSavingObject
{
    return nil;
}

#pragma mark - Controls actions

- (NSMutableArray*)resultArrayFromIndexes
{
    NSInteger selectedCertificatesCount = 0;

    NSEnumerator *indexesEnumerator = [selectedCertificatesIndexesDictionary objectEnumerator];
    NSIndexSet *currentIndexSet;
    while((currentIndexSet = [indexesEnumerator nextObject]))
    {
        selectedCertificatesCount += currentIndexSet.count;
    }
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:selectedCertificatesCount];
    
    // enumerate through storages for each index set
    [selectedCertificatesIndexesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //NSArray *availableCertificates = [self currentSelectedStoreCertificates];
        NSArray *availableCertificates = [storagesDictionary objectForKey:key];
        [(NSIndexSet*)obj enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            CertificateInfo *certInfo = [availableCertificates objectAtIndex:idx];
            [resultArray addObject:certInfo];
        }];
    }];
    
    return resultArray;
}

- (void)actionSaveEncRecievers
{
    NSMutableArray *returnArray = [self resultArrayFromIndexes];
    parentProfile.recieversCertificates = returnArray;
    
    [parentNavController.navCtrlr popViewControllerAnimated:YES];
}

- (void)actionSaveCertsForValidation
{
    NSArray *resultArray = [self resultArrayFromIndexes];
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    for(CertificateInfo* currentCert in resultArray)
    {
        [returnArray addObject:[Profile certificateIdForValidationFromCert:currentCert]];
    }
    
    parentProfile.certsForCrlValidation = returnArray;
    [parentNavController.navCtrlr popViewControllerAnimated:YES];
}

- (void)actionSelectStoreMy
{
    [self selectStore:CST_MY];
    [self.tableView reloadData];
}

- (void)actionSelectStoreAdressBook
{
    [self selectStore:CST_ADDRESS_BOOK];
    [self.tableView reloadData];
}

- (void)actionSelectStoreCa
{
    [self selectStore:CST_CA];
    [self.tableView reloadData];
}

- (void)actionSelectStoreRoot
{
    [self selectStore:CST_ROOT];
    [self.tableView reloadData];
}


#pragma mark - Search display delegate and search bar delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.filterString = searchString;
    [self applyFiltering];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    self.filterScope = searchOption;
    [self applyFiltering];
    
    switch (searchOption) {
        case SVI_ISSUER:
        case SVI_SUBJECT:
            searchController.searchBar.prompt = nil;
            break;
            
        case SVI_VALID_FROM:
        case SVI_VALID_TO:
            searchController.searchBar.prompt = NSLocalizedString(@"PROFILE_SEL_CERT_DATE_FORMAT", @"date format: YYYY-MM-DD");
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    isFiltered = YES;
    //TODO: is it possible to set up search bar view?
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    isFiltered = NO;
    [self.tableView reloadData];
}

- (void)applyFiltering
{
    NSUInteger certificatesFound = 0;
    
    NSArray *availableCertificates = [self currentSelectedStoreCertificates];
    int certCount = availableCertificates.count;
    NSMutableDictionary *tempIndexesDict = [self currentStoreFilteringMap];
    [tempIndexesDict removeAllObjects];

    for( int i = 0; i <  certCount; i++ )
    {
        CertificateInfo *currentCert = [availableCertificates objectAtIndex:i];
        
        switch (self.filterScope)
        {
            //subject name
            case SVI_SUBJECT:
            {
                NSString *subjectName = [Profile getDnStringInMSStyle:currentCert.x509->cert_info->subject];
                
                NSRange foundRange = [subjectName rangeOfString:self.filterString options:NSCaseInsensitiveSearch];
                if( foundRange.location != NSNotFound )
                {
                    [tempIndexesDict setObject:[NSNumber numberWithInt:i] forKey:[NSNumber numberWithInt:certificatesFound]];
                    certificatesFound++;
                }
            }
                break;
             
            //issuer name
            case SVI_ISSUER:
            {
                NSString *issuerName = [Profile getDnStringInMSStyle:currentCert.x509->cert_info->issuer];
                
                NSRange foundRange = [issuerName rangeOfString:self.filterString options:NSCaseInsensitiveSearch];
                if( foundRange.location != NSNotFound )
                {
                    [tempIndexesDict setObject:[NSNumber numberWithInt:i] forKey:[NSNumber numberWithInt:certificatesFound]];
                    certificatesFound++;
                }
            }
                break;
            
            //valitity period beginning or ending
            case SVI_VALID_FROM:
            case SVI_VALID_TO:
            {
                time_t currentCertTimeInterval = (SVI_VALID_FROM==self.filterScope) ? currentCert.validFrom : currentCert.validTo;
                NSDate *currentCertDate = [NSDate dateWithTimeIntervalSince1970:currentCertTimeInterval];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd";
                NSString *currentCertDateString = [formatter stringFromDate:currentCertDate];
                [formatter release];

                if( 0 == [currentCertDateString rangeOfString:filterString].location )
                {
                    [tempIndexesDict setObject:[NSNumber numberWithInt:i] forKey:[NSNumber numberWithInt:certificatesFound]];
                    certificatesFound++;
                }
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Additional methods

- (void)selectStore:(enum CERT_STORE_TYPE)storeToSelect
{
    currentSelectedStoreType = storeToSelect;
    
    NSMutableArray *extractedCertificates = [self currentSelectedStoreCertificates];
    if( extractedCertificates.count )
    {
        return;
    }
    
    CertificateStore *selectingStore = [[CertificateStore alloc] initWithStoreType:storeToSelect];
    [extractedCertificates addObjectsFromArray:selectingStore.certificates];
    [selectingStore release];
    
    // Filtering certificates by usages
    NSArray *filteringOids = nil;
    switch (pageType) {
        case SCPT_SIGN_CERT:
            filteringOids = parentProfile.signCertFilter;
            break;
            
        case SCPT_ENCRYPT_CERT:
            filteringOids = parentProfile.encryptCertFilter;
            break;
            
        default:
            break;
    }
    
    if( filteringOids && filteringOids.count )
    {
        NSMutableArray *filteredCertificates = [[NSMutableArray alloc] initWithCapacity:extractedCertificates.count];
        BOOL oidNotFound;
        
        for (CertificateInfo *currentCert in extractedCertificates)
        {
            //Oids filtering code
            oidNotFound = YES;
            
            NSArray *currentCertUsages = [self extendedKeyUsageFromCert:currentCert.x509];
            if( !currentCertUsages )
            {
                //No usages found - cert unable to correspond to any usage from filter
                continue;
            }
            
            // Enumerate oids from filter
            for (CertUsage *currentFilteringOid in filteringOids)
            {
                oidNotFound = YES;
                
                // Enumerate oids from certificate
                for (NSString *currentCertUsageId in currentCertUsages) {
                    if( [currentFilteringOid.usageId compare:currentCertUsageId] == NSOrderedSame )
                    {
                        oidNotFound = NO;
                        // Proceed to next OID from filter
                        break;
                    }
                }
                
                // If OID not found we can discard this certificate
                if( oidNotFound )
                {
                    break;
                }
            }
            
            // Discarding certificate
            if( oidNotFound )
            {
                continue;
            }
            
            [filteredCertificates addObject:currentCert];
        }
        
        [extractedCertificates removeAllObjects];
        [extractedCertificates addObjectsFromArray:filteredCertificates];
        [filteredCertificates release];
    }
}

- (NSArray*)extendedKeyUsageFromCert:(X509*)x509Cert
{
    EXTENDED_KEY_USAGE *extKeyUsages = X509_get_ext_d2i(x509Cert, NID_ext_key_usage, NULL, NULL);
    int usagesNumber = sk_ASN1_OBJECT_num(extKeyUsages);
    if( usagesNumber < 0 )
    {
        return nil;
    }
    
    NSMutableArray* resultEku = [[NSMutableArray alloc] initWithCapacity:usagesNumber];
    
    for( int i = 0; i < usagesNumber; i++ )
    {
        ASN1_OBJECT *currentUsage = sk_ASN1_OBJECT_value(extKeyUsages, i);
        [resultEku addObject:[Crypto convertAsnObjectToString:currentUsage noName:YES]];
    }
    
    return [resultEku autorelease];
}


- (NSIndexSet*)storesAvailableForPageType:(enum ENM_SEL_CERT_PAGE_TYPE)listType
{
    NSMutableIndexSet *resultIdexSet = [[NSMutableIndexSet alloc] init];
    
    switch (listType) {
        case SCPT_SIGN_CERT:
        case SCPT_ENCRYPT_CERT:
        case SCPT_RECIEVERS_CERTS:
        case SCPT_VALIDATION_CERTS:
        {
            [resultIdexSet addIndex:CST_MY];
            [resultIdexSet addIndex:CST_ADDRESS_BOOK];
            [resultIdexSet addIndex:CST_CA];
            [resultIdexSet addIndex:CST_ROOT];
        }
            break;
            
        case SCPT_DECRYPT_CERT:
        {
            [resultIdexSet addIndex:CST_MY];
        }
            break;
            
        default:
            break;
    }
    
    return [resultIdexSet autorelease];
}

- (enum CERT_STORE_TYPE)defaultStoreForPageType:(enum ENM_SEL_CERT_PAGE_TYPE)listType
{
    switch (listType) {
        case SCPT_SIGN_CERT:
        case SCPT_ENCRYPT_CERT:
        case SCPT_DECRYPT_CERT:
        case SCPT_VALIDATION_CERTS:
            return CST_MY;
            break;
            
        case SCPT_RECIEVERS_CERTS:
            return CST_ADDRESS_BOOK;
            break;
            
        default:
            break;
    }
    
    return CST_MY;
}

- (NSMutableArray*)currentSelectedStoreCertificates
{
    if( !storagesDictionary )
    {
        storagesDictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    NSMutableArray *currentCertsArray = [storagesDictionary objectForKey:[NSNumber numberWithInt:currentSelectedStoreType]];
    if( !currentCertsArray )
    {
        currentCertsArray = [[[NSMutableArray alloc] init] autorelease];
        [storagesDictionary setObject:currentCertsArray forKey:[NSNumber numberWithInt:currentSelectedStoreType]];
    }
    
    return currentCertsArray;
}

- (NSMutableDictionary*)currentStoreFilteringMap
{
    if( !filteredCertificatsMapsDictionary )
    {
        filteredCertificatsMapsDictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    NSMutableDictionary *currentFilteringMap = [filteredCertificatsMapsDictionary objectForKey:[NSNumber numberWithInt:currentSelectedStoreType]];
    if( !currentFilteringMap )
    {
        currentFilteringMap = [[[NSMutableDictionary alloc] init] autorelease];
        [filteredCertificatsMapsDictionary setObject:currentFilteringMap forKey:[NSNumber numberWithInt:currentSelectedStoreType]];
    }
    
    return currentFilteringMap;
}

- (NSMutableIndexSet*)currentStoreSelectedCertsIndex
{
    if( !selectedCertificatesIndexesDictionary )
    {
        selectedCertificatesIndexesDictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    NSMutableIndexSet *currentFilteringMap = [selectedCertificatesIndexesDictionary objectForKey:[NSNumber numberWithInt:currentSelectedStoreType]];
    if( !currentFilteringMap )
    {
        currentFilteringMap = [[[NSMutableIndexSet alloc] init] autorelease];
        [selectedCertificatesIndexesDictionary setObject:currentFilteringMap forKey:[NSNumber numberWithInt:currentSelectedStoreType]];
    }
    
    return currentFilteringMap;
}

- (NSString*)storeNameByType:(enum CERT_STORE_TYPE)storeType
{
    switch (storeType) {
        case CST_MY:
            return NSLocalizedString(@"Личное", @"Личное");
            break;
            
        case CST_ADDRESS_BOOK:
            return NSLocalizedString(@"Других пользователей", @"Других пользователей");
            break;
            
        case CST_CA:
            return NSLocalizedString(@"Промежуточные центры сертификации", @"Промежуточные центры сертификации");
            break;
            
        case CST_ROOT:
            return NSLocalizedString(@"Корневые сертификаты", @"Корневые сертификаты");
            break;
            
        default:
            break;
    }
    
    return @"Name not supported for this type";
}

#pragma mark - SettingMenuSource delegate

- (UITableViewCellAccessoryType)accessoryTypeForCell:(NSIndexPath *)cellIndex
{
    // Add checkmark to selected store line
    UITableViewCellAccessoryType resultType = UITableViewCellAccessoryNone;
    
    NSIndexSet *availableStoresSet = [self storesAvailableForPageType:pageType];

    // Correspondence of cert ID's (values) to index in menu (keys)
    NSMutableDictionary *storesDictionary = [[NSMutableDictionary alloc] initWithCapacity:availableStoresSet.count];
    [availableStoresSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [storesDictionary setObject:[NSNumber numberWithUnsignedInteger:idx] forKey:[NSNumber numberWithUnsignedInteger:storesDictionary.count]];
    }];
    
    // Retrieve current cell store ID by cell index
    NSNumber *currentCellStore = [storesDictionary objectForKey:[NSNumber numberWithUnsignedInteger:cellIndex.row]];
    if( currentCellStore.unsignedIntegerValue == currentSelectedStoreType )
    {
        resultType = UITableViewCellAccessoryCheckmark;
    }
    
    [storesDictionary release];
    return resultType;
}

@end
