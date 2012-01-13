//
//  CertStoreViewController.m
//  CryptoARM
//
//  Created by Денис Бурдин on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CertStoreViewController.h"

@implementation CertStoreViewController

@synthesize parentController, saveButton, isShowingLandscapeView, tblCerts, selectedPerson;

- (id)initWithNibName:(NSString *)nibNameOrNil andPerson:(ABRecordRef)somePerson bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        selectedPerson = somePerson;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // extract all unattached certificates with attached to current person record certificates
    CRYPTO_malloc_init();
	ERR_load_crypto_strings();
	OpenSSL_add_all_algorithms();
	ENGINE_load_builtin_engines();

    // initialize array of records in the address book
    ABAddressBookRef addressBook = ABAddressBookCreate();
    NSArray * people = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    STACK_OF(X509) *skCertsAll = sk_X509_new_null(); // all certs in the cert store which are already attached
    skPersonCerts = sk_X509_new_null();
    skUnattachedCerts = sk_X509_new_null();
    skAllPresentedCerts = sk_X509_new_null();
    
    for (int j = 0; j < [people count]; j++)
    {        
        // extract cert url in the AddressBook person record
        ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        urlMultiValue = ABRecordCopyValue((ABRecordRef)[people objectAtIndex:j], kABPersonURLProperty);

        ABRecordID firstRecordID = ABRecordGetRecordID((ABRecordRef)[people objectAtIndex:j]);
        ABRecordID secondRecordID = ABRecordGetRecordID(selectedPerson);
        
        if (firstRecordID == secondRecordID)
        {
            // this certs will be marked as selected
            [Crypto getCertificatesFromURL:skPersonCerts withURLCertList:urlMultiValue andStore:@"AddressBook"];
        }
        else
        {
            [Crypto getCertificatesFromURL:skCertsAll withURLCertList:urlMultiValue andStore:@"AddressBook"];
        }
    }

    // firstly attached certs are shown; secondly - all other unattached certs
    for (int i = 0; i < sk_X509_num(skPersonCerts); i++)
    {
        sk_X509_push(skAllPresentedCerts, sk_X509_value(skPersonCerts, i));
    }
    
    for (int i = 0; i < sk_X509_num(skCertsAll); i++)
    {
        sk_X509_push(skAllPresentedCerts, sk_X509_value(skCertsAll, i));
    }
    
    // create temporary certificate binding to the address book store record
    ENGINE *e = ENGINE_by_id(CTIOSRSA_ENGINE_ID);
    STORE *store = STORE_new_engine(e);
    
    STORE_ctrl(store, CTIOSRSA_STORE_CTRL_SET_NAME, 0, "AddressBook", NULL);

    void *handle = nil;
    OPENSSL_ITEM emptyAttrs[] = {{ STORE_ATTR_END }};
    OPENSSL_ITEM emptyParams[] = {{ STORE_PARAM_KEY_NO_PARAMETERS }};

	if ((handle = STORE_list_certificate_start(store, emptyAttrs, emptyParams)))
	{
    	for (int i = 0; !STORE_list_certificate_endp(store, handle); i++)
        {
            X509 *cert = STORE_list_certificate_next(store, handle);
            
            if (cert)
            {
                // try to find it among address book certs attached to any person record(by URL)
                if (sk_X509_find(skCertsAll, cert))
                {
                    X509_FREE(cert);
                    continue;
                }
                else
                {
                    sk_X509_push(skUnattachedCerts, cert);
                }
            }
            else
            {
                // print error;
            }
        }
	}
    else
    {
        // print error;
    }
    
    // add callback watch device orientation changed selector
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // find out current device orientation
    isShowingLandscapeView = NO;
    
    if (self.navigationController.view.frame.size.width < 768)
    {
        // landscape orientation
        isShowingLandscapeView = YES;
    }
    else
    {
        isShowingLandscapeView = NO;        
    }

    // build certificates table
    tblCerts.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tblCerts.dataSource = self;
    tblCerts.delegate = self;
    
    [tblCerts reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
    {
        isShowingLandscapeView = YES;
        [tblCerts reloadData];
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
    {
        isShowingLandscapeView = NO;
        [tblCerts reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc
{
    [parentController release];
    [tblCerts release];
    
    sk_X509_free(skPersonCerts);
    sk_X509_free(skUnattachedCerts);
    
    if ( saveButton )
    {
        [saveButton release];
    }
    
    [super dealloc];
}

#pragma mark - NavigationSource protocol support

+ (NSString*)itemTag
{
    return @"CertStoreViewController";
}

- (NSString*)itemTag
{
    return [CertStoreViewController itemTag];
}

- (NSString*)title
{
    return NSLocalizedString(@"CERTIFICATES", @"CERTIFICATES");
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
    NSMutableArray *arrAdditionalButtons = [[[NSMutableArray alloc] init] autorelease];
    
    // save settings button (Done)
    if ( !saveButton )
    {
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [customButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        customButton.frame = CGRectMake(0, 0, 100, 32);
        [customButton setBackgroundColor:[UIColor colorWithRed:0.502 green:0.089 blue:0.013 alpha:1.000]];
        [customButton setTitle:NSLocalizedString(@"BUTTON_DONE", @"BUTTON_DONE") forState:UIControlStateNormal];
        [customButton.layer setCornerRadius:5.0];
        
        saveButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    }
    
    [arrAdditionalButtons addObject:saveButton];
    
    return arrAdditionalButtons;
}

- (void)saveButtonAction:(id)sender
{
    if ( parentController )
    {
        [parentController dismissPopovers];
    }

    // now forming a new list skPersonCerts with updated attached certs
    int iCertCount = sk_X509_num(skUnattachedCerts) + sk_X509_num(skPersonCerts);
    sk_X509_zero ( skPersonCerts );

    for (int i = 0; i < iCertCount; i++)
    {
        CertificateStoreCellView *cell = (CertificateStoreCellView *)[tblCerts cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];

        if (cell.isChecked)
        {
            sk_X509_push(skPersonCerts, cell.cert->x509);
        }
    }

    // reattach certificates
    ABAddressBookRef addressBook = ABAddressBookCreate();
    NSArray *people = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    if ((people != nil) && [people count])
    {
        CFErrorRef error = NULL;
        
        for (int i = 0; i < [people count]; i++)
        {                  
            ABRecordRef person = (ABRecordRef)[people objectAtIndex:i];
            
            ABRecordID firstRecordID = ABRecordGetRecordID((ABRecordRef)[people objectAtIndex:i]);
            ABRecordID secondRecordID = ABRecordGetRecordID(selectedPerson);

            if (firstRecordID != secondRecordID)
            {
                continue;
            }

            ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);

            for (int  k = 0; k < sk_X509_num(skPersonCerts); k++)
            {
                X509 *cert = sk_X509_value(skPersonCerts, k);
                    
                // create hash on it(to compare with cert hash attribute in store)
                PKCS7_ISSUER_AND_SERIAL issuerAndSerial = {};
                issuerAndSerial.issuer = cert->cert_info->issuer;
                issuerAndSerial.serial = cert->cert_info->serialNumber;
                    
                unsigned char *szHash = (unsigned char *)malloc(256);
                unsigned char *szHashValue = (unsigned char *)malloc(256);
                    
                szHash[0] = '\0';
                szHashValue[0] = '\0';
                unsigned int length = 0;
                    
                if (PKCS7_ISSUER_AND_SERIAL_digest(&issuerAndSerial, EVP_sha1(), szHash, &length) <= 0)
                {
                    return; // TODO: throw error
                }

                NSString *hexData = [Utils hexDataToString:szHash length:length isNeedSpacing:NO];
                int len = 0;
                szHashValue = X509_keyid_get0(cert, &len);

                // add URL to the person
                NSMutableString *strCertURL = [[NSMutableString alloc] initWithCString:"cryptoarm://certificate/" encoding:NSASCIIStringEncoding];
                [strCertURL appendString:[NSString stringWithCString:[hexData cStringUsingEncoding:NSASCIIStringEncoding] encoding:NSASCIIStringEncoding]];
                    
                ABMultiValueAddValueAndLabel(urlMultiValue, strCertURL, kABOtherLabel, NULL);
            }
                
            CFErrorRef *errorAddrBook;
            ABRecordSetValue(person, kABPersonURLProperty, urlMultiValue, errorAddrBook);
            CFRelease(urlMultiValue);
            
            break;
        }
            
        // save changes to the address book
        ABAddressBookSave(addressBook, &error);
    }
    
    CFRelease(addressBook);
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [allViewControllers removeObjectIdenticalTo:self];
    self.navigationController.viewControllers = allViewControllers;
    
    [(AddressBookCertificateBindingManager *)[allViewControllers objectAtIndex:([allViewControllers count] - 1)] updateCertList:skPersonCerts];
}

- (void)setParentNavigationController:(UIViewController*)navController
{
    parentController = (DetailNavController*)navController;
}

- (BOOL)preserveController
{
    return FALSE;
}

- (Class)getSavingObjcetClass
{
    //TODO: implement, if necessary
    return [self class];
}

- (UINavigationItem<MenuDataRefreshinProtocol>*)createSavingObject
{
    //TODO: implement, if necessary
    return nil;
}

#pragma mark table view controller delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sk_X509_num(skUnattachedCerts) + sk_X509_num(skPersonCerts); // number of unattached certificates with attached to current person record certificates
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *nib;
    NSString *CellIdentifier;
    
    if (isShowingLandscapeView)
    {
        nib = [[NSBundle mainBundle] loadNibNamed:@"CertificateStoreCellViewLandscape" owner:self options:nil];
        CellIdentifier = [NSString stringWithFormat:@"CertificateStoreCellViewLandscape %d %d", indexPath.section, indexPath.row];
    }
    else
    {
        nib = [[NSBundle mainBundle] loadNibNamed:@"CertificateStoreCellViewPortrait" owner:self options:nil];
        CellIdentifier = [NSString stringWithFormat:@"CertificateStoreCellViewPortrait %d %d", indexPath.section, indexPath.row];
    }
     
    CertificateStoreCellView *cell = (CertificateStoreCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = (CertificateStoreCellView *)[nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // set cell info
        // add action to the button
        [cell.btnShowCert setTitle:[NSString stringWithFormat:@"%d", indexPath.row] forState:UIControlStateNormal];
        [cell.btnShowCert addTarget:self action:@selector(performSelectorOnCellButton:) forControlEvents:UIControlEventTouchUpInside];

        [cell.imgCert performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:@"cert-valid.png"] waitUntilDone:YES];

        if ( sk_X509_num(skUnattachedCerts) || sk_X509_num(skPersonCerts) )
        {
            // at first show unattached certificates
            X509_INFO *selectedCert = X509_INFO_new();

            if (sk_X509_num(skPersonCerts) > indexPath.row)
            {
                selectedCert->x509 = sk_X509_value(skPersonCerts, indexPath.row);
                [cell.imgTick setImage:[UIImage imageNamed:@"checked.PNG"]];
                cell.isChecked = YES;
            }
            else
            {
                selectedCert->x509 = sk_X509_value(skUnattachedCerts, indexPath.row - sk_X509_num(skPersonCerts));
                [cell.imgTick setImage:[UIImage imageNamed:@"unchecked.PNG"]];
                cell.isChecked = NO;
            }

            cell.cert = [[[CertificateInfo alloc] initWithX509_INFO:selectedCert] autorelease];

            // parsing X509_INFO
            time_t validTo = cell.cert.validTo; // cert expires date
            
            // set language from CryptoARM settings pane
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
            NSString* selectedLanguage = [languages objectAtIndex:0];
            NSString *localeIdentifier;
            
            if ([selectedLanguage isEqualToString:@"ru"])
            {
                localeIdentifier = @"ru_RU";
            }
            else if ([selectedLanguage isEqualToString:@"en"])
            {
                localeIdentifier = @"en_EN";
            }
            
            NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
            NSDate *expiresDate = [NSDate dateWithTimeIntervalSince1970:validTo];
            
            // this converts the date to a string
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:locale];
            [dateFormatter setFormatterBehavior:NSDateFormatterBehaviorDefault];
            
            // get the name of the month
            [dateFormatter setDateFormat:@"MMMM"];
            NSString * monthName = [dateFormatter stringFromDate:expiresDate];
            
            // extract date and year from time_t
            char szDate[5], szYear[5];
            szDate[0] = '\0'; szYear[0] = '\0';
            strftime(szDate, 5, "%d", localtime(&validTo));
            strftime(szYear, 5, "%Y", localtime(&validTo));    
            
            [cell.lblSubject setText:[Crypto getDNFromX509_NAME:cell.cert.subject withNid:NID_commonName]];
            
            [cell.lblCertIssuer setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"CERT_WHO_ISSUED", @"CERT_WHO_ISSUED"), [Crypto getDNFromX509_NAME:cell.cert.issuer withNid:NID_commonName]]];
            
            [cell.lblValidTo setText:[NSString stringWithFormat:@"%@: %s %@ %s %@.", NSLocalizedString(@"CERT_EXPIRED", @"CERT_EXPIRED"), szDate, monthName, szYear, NSLocalizedString(@"YEAR_PREFIX", @"YEAR_PREFIX")]];
        }
        else
        {
            // TODO: paste empty image(or nocert image) if cert url is abscent
            // [cell.imgCert performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:@"cert-valid.png"] waitUntilDone:YES];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CertificateStoreCellView *cell = (CertificateStoreCellView *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.isChecked)
    {
        cell.isChecked = NO;
        [cell.imgTick setImage:[UIImage imageNamed:@"unchecked.PNG"]];

        // remove cert from the stack of selected certificate
        for (int i = 0; i < sk_X509_num(skPersonCerts); i++)
        {
            if ( !X509_cmp(sk_X509_value(skPersonCerts, i), cell.cert->x509) )
            {
                sk_X509_delete(skPersonCerts, i);

                // push cert to unattached certs
                sk_X509_push(skUnattachedCerts, cell.cert->x509);
                break;
            }
        }
    }
    else
    {
        cell.isChecked = YES;
        [cell.imgTick setImage:[UIImage imageNamed:@"checked.PNG"]];
        
        // remove cert from unattached certs(if any)
        for (int i = 0; i < sk_X509_num(skUnattachedCerts); i++)
        {
            if ( !X509_cmp(sk_X509_value(skUnattachedCerts, i), cell.cert->x509) )
            {
                sk_X509_delete(skUnattachedCerts, i);

                // add cert to the stack of selected certificate
                sk_X509_push(skPersonCerts, cell.cert->x509);
                
                break;
            }
        } 
    }
}

- (void)performSelectorOnCellButton:(id)sender
{
    UIButton *button = sender;
    
    X509_INFO *selectedCert = X509_INFO_new();
    selectedCert->x509 = sk_X509_value(skAllPresentedCerts, [button.titleLabel.text intValue]);

    CertificateInfo *certInfo = [[CertificateInfo alloc] initWithX509_INFO:selectedCert];
    [parentController pushNavController:[[CertDetailViewController alloc] initWithCertInfo:certInfo]];
}

@end
