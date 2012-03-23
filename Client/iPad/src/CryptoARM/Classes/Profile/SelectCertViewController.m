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
@synthesize filteredCertificatesMap;
@synthesize filterString;
@synthesize filterScope;

- (UIImage*)constructImageWithStatus:(UIImage*)statusImage andCheckButton:(UIImage*)checkButton
{
    UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 80)];
    
    UIImageView *checkView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 28, 25, 24)];
    checkView.image = checkButton;
    UIImageView *statusView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, 80, 80)];
    statusView.image = statusImage;
    
    [imageView addSubview:statusView];
    [imageView addSubview:checkView];
    
    UIGraphicsBeginImageContext(imageView.bounds.size);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [imageView release];
    [checkView release];
    [statusView release];
    
    return [resultImage retain];
}

- (id)initWithProfile:(Profile *)profile andSelectType:(enum ENM_SEL_CERT_PAGE_TYPE)listType;
{
    self = [super init];
    if(self)
    {
        self.parentProfile = profile;
        pageType = listType;
        currentSelectedStoreType = ST_DEFAULT;
        
        filteredCertificatesMap = nil;
        isFiltered = NO;
        self.filterScope = 0;
        self.filterString = @"";
        
        if( (SCPT_RECIEVERS_CERTS == pageType) || (SCPT_VALIDATION_CERTS == pageType) )
        {
            checkedValid = [self constructImageWithStatus:[UIImage imageNamed:@"cert-valid.png"] andCheckButton:[UIImage imageNamed:@"checked.PNG"]];
            uncheckedValid = [self constructImageWithStatus:[UIImage imageNamed:@"cert-valid.png"] andCheckButton:[UIImage imageNamed:@"unchecked.PNG"]];
            //TODO: add invalid status images?
            
            personalStorageIndex = [[NSMutableIndexSet alloc] init];
            
            NSMutableArray *certsFromProfile;
            if( SCPT_RECIEVERS_CERTS == pageType)
            {
                certsFromProfile = [[NSMutableArray alloc] initWithArray:self.parentProfile.recieversCertificates];
            }
            else if( SCPT_VALIDATION_CERTS )
            {
                certsFromProfile = [[NSMutableArray alloc] initWithArray:self.parentProfile.certsForCrlValidation];
            }
            
            //TODO: cycle or manually process storages and add indexes
            {
                [self selectStore:currentSelectedStoreType];
                
                //enumerate certs in profile
                NSMutableIndexSet *foundProfileCertsIndex = [[NSMutableIndexSet alloc] init];
                
                for (id currentProfileCertObject in certsFromProfile)
                {
                    for( int i = 0; i < (availableCertificates->stack.num); i++ )
                    {
                        //skip already founded certificates
                        if( [personalStorageIndex containsIndex:(NSUInteger)i] )
                        {
                            continue;
                        }
                        
                        if( SCPT_RECIEVERS_CERTS == pageType )
                        {
                            CertificateInfo* currentProfileCert = (CertificateInfo*)currentProfileCertObject;
                            
                            if( !X509_issuer_and_serial_cmp(currentProfileCert.x509, sk_X509_value(availableCertificates, i)) )
                            {
                                //if cert is match, remember it's index in store and index in profile array
                                [personalStorageIndex addIndex:(NSInteger)i];
                                [foundProfileCertsIndex addIndex:[certsFromProfile indexOfObject:currentProfileCert]];
                                break;
                            }
                        }
                        else if( SCPT_VALIDATION_CERTS == pageType )
                        {
                            NSString *currentProfileCertIdString = (NSString*)currentProfileCertObject;
                            
                            CertificateInfo *storageCert = [[CertificateInfo alloc] initWithX509:sk_X509_value(availableCertificates, i)];
                            if( [Profile isCertificate:storageCert correspondsToIdString:currentProfileCertIdString] )
                            {
                                //if cert is match, remember it's index in store and index in profile array
                                [personalStorageIndex addIndex:(NSInteger)i];
                                [foundProfileCertsIndex addIndex:[certsFromProfile indexOfObject:currentProfileCertIdString]];
                                [storageCert release];
                                break;
                            }
                            
                            [storageCert release];
                        }
                    }   
                }

                //remove already founded certs from array to enumerate smaller number of certs in next store
                [certsFromProfile removeObjectsAtIndexes:foundProfileCertsIndex];
                [foundProfileCertsIndex release];
            }
            
            [certsFromProfile release];
        }
    }
    return self;
}

- (void)dealloc
{
    [checkedValid release];
    [uncheckedValid release];
    
    if( personalStorageIndex )
    {
        [personalStorageIndex release];
    }
    
    if( filteredCertificatesMap )
    {
        [filteredCertificatesMap release];
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

    //TODO: default store depends from page type
    switch (pageType)
    {
//        case SCPT_RECIEVERS_CERTS:
//            //...
//            break;

        default:
            [self selectStore:ST_DEFAULT];
            break;
    }
    
    self.tableView.contentOffset = CGPointMake(0,  44);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [searchController release];
    
    sk_X509_free(availableCertificates);
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
        return filteredCertificatesMap.count;
    }
    
    return sk_X509_num(availableCertificates);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectCertForProfileCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    X509 *currentCert = nil;
    NSNumber *certIndex = nil;
    if( isFiltered )
    {
        certIndex = [filteredCertificatesMap objectForKey:[NSNumber numberWithInt:indexPath.row]];
        if( certIndex )
        {
            currentCert = sk_X509_value(availableCertificates, certIndex.intValue);
        }
        else
        {
            NSLog(@"Error: index not found in map!");
        }
    }
    else
    {
        currentCert = sk_X509_value(availableCertificates, indexPath.row);
    }
    CertificateInfo *currentCertObject = [[CertificateInfo alloc] initWithX509:currentCert];
    
    cell.textLabel.text = [Crypto getDNFromX509_NAME:currentCertObject.subject withNid:NID_commonName];
    cell.detailTextLabel.numberOfLines = 2;
    
    
    //-------------------------------------
    time_t validTo = currentCertObject.validTo; // cert expires date
    
    // Set language from CryptoARM settings pane
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
    NSString* selectedLanguage = [languages objectAtIndex:0];
    NSString *localeIdentifier = @"ru_RU";
    
    if ([selectedLanguage isEqualToString:@"ru"])
    {
        localeIdentifier = @"ru_RU";
    }
    else if ([selectedLanguage isEqualToString:@"en"])
    {
        localeIdentifier = @"en_EN";
    }
    
    NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
    NSDate *dateOfExpiration = [NSDate dateWithTimeIntervalSince1970:validTo];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = locale;
    formatter.dateStyle = NSDateFormatterLongStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    
    NSString *certExpirationDate = [formatter stringFromDate:dateOfExpiration];
    
    [locale release];
    [formatter release];
    
    //-------------------------------------
    NSString *certIssuer = [Crypto getDNFromX509_NAME:currentCertObject.issuer withNid:NID_commonName];
    //-------------------------------------                               
    
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Кем выдан:%@\nИстекает: %@", certIssuer, certExpirationDate];
    
    [currentCertObject release];
    
    switch (pageType) {
        case SCPT_SIGN_CERT:
        case SCPT_ENCRYPT_CERT:
            //TODO: check certificate status and draw appropriate image
            [cell.imageView setImage:[UIImage imageNamed:@"cert-valid.png"]];
            break;
            
        case SCPT_RECIEVERS_CERTS:
        case SCPT_VALIDATION_CERTS:
        {
            //TODO: check certificate status and draw appropriate image
            //TODO: select index relative to current displaying store
            NSUInteger mappedIndex = isFiltered ? certIndex.intValue : indexPath.row;
            if( [personalStorageIndex containsIndex:mappedIndex] )
            {
                cell.imageView.image = checkedValid;
            }
            else
            {
                cell.imageView.image = uncheckedValid;
            }
        }
            break;
            
        default:
            break;
    }
    
//    if( certIndex )
//    {
//        [certIndex release];
//    }
    
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
    
    X509 *selectedCert = nil;
    NSNumber *certIndex = nil;
    if( isFiltered )
    {
        certIndex = [filteredCertificatesMap objectForKey:[NSNumber numberWithInt:indexPath.row]];
        if( certIndex )
        {
            selectedCert = sk_X509_value(availableCertificates, certIndex.intValue);
        }
        else
        {
            NSLog(@"Error: index not found in map!");
        }
    }
    else
    {
        selectedCert = sk_X509_value(availableCertificates, indexPath.row);
    }
    
    
    switch (pageType) {
        case SCPT_SIGN_CERT:
        {
            self.parentProfile.signCertificate = [[[CertificateInfo alloc] initWithX509:selectedCert] autorelease];
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
            
            self.parentProfile.encryptCertificate = [[[CertificateInfo alloc] initWithX509:selectedCert] autorelease];
            
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
            //TODO: cycle through available storages
            NSUInteger selectedIndex = isFiltered ? certIndex.intValue : indexPath.row;
            
            if( [personalStorageIndex containsIndex:selectedIndex] )
            {
                [personalStorageIndex removeIndex:selectedIndex];
            }
            else
            {
                [personalStorageIndex addIndex:selectedIndex];
            }
            
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        case SCPT_DECRYPT_CERT:
        {
            self.parentProfile.decryptCertificate = [[[CertificateInfo alloc] initWithX509:selectedCert] autorelease];
            [parentNavController.navCtrlr popViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
    }

//    if( certIndex )
//    {
//        [certIndex release];
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //TODO: show storage title
    return @"Storage title";
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
    return nil;
}

- (void)constructSettingsMenu
{
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
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:personalStorageIndex.count]; //+ count of other indexes
    
    //TODO: enumerate through storages for each index
    {
        [personalStorageIndex enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            CertificateInfo *certInfo = [[CertificateInfo alloc] initWithX509:sk_X509_value(availableCertificates, idx)];
            [resultArray addObject:certInfo];
            [certInfo release];
        }];
    }
    
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

- (void)selectStore:(enum ENM_STORE_TYPE)storeToSelect
{
    //TODO: check dictionary. If certificates from requested store already readed into
    //      dictionary, load them from dictinary instead of reading from store
    
    //TODO: filter certs with policies
    // Filtering certificates by usages
    NSArray *filteringOids = nil;
    switch (pageType) {
//        case SCPT_SIGN_CERT:
//            <#statements#>
//            break;
            
        case SCPT_ENCRYPT_CERT:
            filteringOids = parentProfile.encryptCertFilter;
            break;
            
        default:
            break;
    }
    
    // extract certs bound to the person record
    ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    // TODO: implement rebuilding stack after change certificates set
    availableCertificates = sk_X509_new_null();
    [Crypto getCertificatesFromURL:availableCertificates withURLCertList:urlMultiValue andStore:@"AddressBook"];
    
    //TODO: remove debug initialization
    STACK_OF(X509_INFO)* infoStack = sk_X509_INFO_new_null();
    for( int i = 0; i < sk_X509_INFO_num(infoStack); i++)
    {
        X509_INFO *currentCert = sk_X509_INFO_value(infoStack, i);

        //Oids filtering code
        if( filteringOids && filteringOids.count )
        {
            BOOL oidNotFound = YES;
            
            NSArray *currentCertUsages = [self extendedKeyUsageFromCert:currentCert->x509];
            if( !currentCertUsages )
            {
                //No usages found - cert unable to correspond to any usage from filter
                continue;
            }
            
            // Enumerate oids from filter
            for (CertUsage *currentFilteringOid in filteringOids)
            {
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
        }
        
        sk_X509_push(availableCertificates, currentCert->x509);
    }
    
    CFRelease(urlMultiValue);
    
//    //Oids filtering code
//    if( filteringOids )
//    {
//        for (CertUsage *currentOid in filteringOids)
//        {
//            //use this "if" before pushing certificate into array of available certificates
//            //currentOid
//        }
//    }
 

    //TODO: put readed certificates to dictionary
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
    
    //self.tableView.contentOffset = CGPointMake(0,  searchController.searchBar.frame.size.height);
}

- (void)applyFiltering
{
    NSUInteger certificatesFound = 0;
    
    int certCount = sk_X509_num(availableCertificates);
    NSMutableDictionary *tempIndexesDict = [[NSMutableDictionary alloc] initWithCapacity:certCount];

    for( int i = 0; i <  certCount; i++ )
    {
        X509 *currentCert = sk_X509_value(availableCertificates, i);
        
        switch (self.filterScope)
        {
            //subject name
            case SVI_SUBJECT:
            {
                NSString *subjectName = [Profile getDnStringInMSStyle:currentCert->cert_info->subject];
                
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
                NSString *issuerName = [Profile getDnStringInMSStyle:currentCert->cert_info->issuer];
                
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
                CertificateInfo* curCert = [[CertificateInfo alloc] initWithX509:currentCert];
                time_t currentCertTimeInterval = (SVI_VALID_FROM==self.filterScope) ? curCert.validFrom : curCert.validTo;
                [curCert release];
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
    
    self.filteredCertificatesMap = tempIndexesDict;
    [tempIndexesDict release];
}

@end
