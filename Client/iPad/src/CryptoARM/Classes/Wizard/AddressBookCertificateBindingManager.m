//
//  AddressBookCertificateBindingManager.m
//  CryptoARM
//
//  Created by Денис Бурдин on 22.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AddressBookCertificateBindingManager.h"

@implementation AddressBookCertificateBindingManager

@synthesize isShowingLandscapeView, tblRecipients, lblOrganization, lblPost, lblEmail, lblOrganizationValue, lblPostValue, lblEmailValue, lblFullPersonName, navDocRecipList, btnAddCertificate, selectedPerson, imgUser;

- (id)initWithNibName:(NSString *)nibNameOrNil andPerson:(ABRecordRef)personRecord bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        selectedPerson = personRecord;
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

    // extract certs bound to the person record
    ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    urlMultiValue = ABRecordCopyValue(selectedPerson, kABPersonURLProperty);

    // TODO: implement rebuilding stack after change certificates set
    skCertFound = sk_X509_new_null();
    [Crypto getCertificatesFromURL:skCertFound withURLCertList:urlMultiValue andStore:@"AddressBook"];
    
    // set person information
    if (ABRecordCopyValue(selectedPerson, kABPersonOrganizationProperty))
    {
        [lblOrganizationValue setText:[NSString stringWithFormat:@"%@", ABRecordCopyValue(selectedPerson, kABPersonOrganizationProperty)]];
        [lblOrganization setText:NSLocalizedString(@"WIZARD_ORGANIZATION", @"WIZARD_ORGANIZATION")];
    }

    if (ABRecordCopyValue(selectedPerson, kABPersonJobTitleProperty))
    {
        [lblPostValue setText:[NSString stringWithFormat:@"%@", ABRecordCopyValue(selectedPerson, kABPersonJobTitleProperty)]];
        [lblPost setText:NSLocalizedString(@"WIZARD_POST", @"WIZARD_POST")];
    }
    
    if (ABRecordCopyValue(selectedPerson, kABPersonEmailProperty))
    {
        ABMultiValueRef emailMultiValue = ABRecordCopyValue(selectedPerson, kABPersonEmailProperty);
        NSArray *emailAddresses = [(NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue) autorelease];

        if (emailAddresses != nil)
        {
            NSString *strEmail = [NSString stringWithFormat:@"%@", [emailAddresses objectAtIndex:0]];
            
            if ([strEmail length])
            {
                [lblEmailValue setText:strEmail];
                [lblEmail setText:@"e-mail"];
            }
        }
    }
    
    NSMutableString *strFullPersonName = [[NSMutableString alloc] init];
    
    if (ABRecordCopyValue(selectedPerson, kABPersonLastNameProperty))
    {
        [strFullPersonName appendString:[NSString stringWithFormat:@"%@", ABRecordCopyValue(selectedPerson, kABPersonLastNameProperty)]];
    }
    
    if (ABRecordCopyValue(selectedPerson, kABPersonFirstNameProperty))
    {
        if ([strFullPersonName length])
        {
            [strFullPersonName appendString:@" "];
        }
        
        [strFullPersonName appendString:[NSString stringWithFormat:@"%@", ABRecordCopyValue(selectedPerson, kABPersonFirstNameProperty)]];
    }
    
    if (ABRecordCopyValue(selectedPerson, kABPersonMiddleNameProperty))
    {
        if ([strFullPersonName length])
        {
            [strFullPersonName appendString:@" "];
        }
        
        [strFullPersonName appendString:[NSString stringWithFormat:@"%@", ABRecordCopyValue(selectedPerson, kABPersonMiddleNameProperty)]];
    }    
    
    [lblFullPersonName setText:strFullPersonName];
    [strFullPersonName release];
    
    if ( ABPersonHasImageData(selectedPerson) )
    {
        // extract user profile image
        CFDataRef userImage = ABPersonCopyImageData(selectedPerson);
        [self.imgUser performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithData:(NSData *)userImage] waitUntilDone:YES];
    }
    else
    {   // set empty image
        [self.imgUser performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:@"cert-valid.png"] waitUntilDone:YES];
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

    // add action to the btnAddRecipients
    [btnAddCertificate setAction:@selector(addCertificate)];
    [btnAddCertificate setTitle:NSLocalizedString(@"WIZARD_ADD_CERT", @"WIZARD_ADD_CERT")];
    
    // build certificates table
    tblRecipients.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tblRecipients.dataSource = self;
    tblRecipients.delegate = self;
    
    [tblRecipients reloadData];
}

- (void)viewDidUnload
{
    [self setTblRecipients:nil];
    [self setLblOrganization:nil];
    [self setLblPost:nil];
    [self setLblEmail:nil];
    [self setLblOrganizationValue:nil];
    [self setLblPostValue:nil];
    [self setLblEmailValue:nil];
    [self setLblFullPersonName:nil];
    [self setNavDocRecipList:nil];
    [self setBtnAddCertificate:nil];
    [self setImgUser:nil];
    
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
        [tblRecipients reloadData];
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
    {
        isShowingLandscapeView = NO;
        [tblRecipients reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc
{
    [tblRecipients release];
    [lblOrganization release];
    [lblPost release];
    [lblEmail release];
    [lblOrganizationValue release];
    [lblPostValue release];
    [lblEmailValue release];
    [lblFullPersonName release];
    [navDocRecipList release];
    [btnAddCertificate release];
    [imgUser release];
    
    if (skCertFound)
    {
        sk_X509_free(skCertFound);
    }
    
    if ( saveButton )
    {
        [saveButton release];
    }
    
    [super dealloc];
}

#pragma mark - NavigationSource protocol support

+ (NSString*)itemTag
{
    return @"AddressBookCertificateBindingManager";
}

- (NSString*)itemTag
{
    return [AddressBookCertificateBindingManager itemTag];
}

- (NSString*)title
{
    return NSLocalizedString(@"WIZARD_CERTIFICATES_BINDING_MANAGER", @"WIZARD_CERTIFICATES_BINDING_MANAGER");
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

    // save changes in the address book person record
    ABAddressBookRef addressBook = ABAddressBookCreate();
    NSArray *people = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);

    for (CFIndex i = 0; i < [people count]; i++)
    {
        // find person by enumeration
        ABRecordID firstRecordID = ABRecordGetRecordID((ABRecordRef)[people objectAtIndex:i]);
        ABRecordID secondRecordID = ABRecordGetRecordID(selectedPerson);
        ABRecordRef currentPerson = (ABRecordRef)[people objectAtIndex:i];
        
        if (firstRecordID == secondRecordID)
        {
            for (CFIndex j = 0; j < sk_X509_num(skCertFound); j++)
            {
                // create hash on it(to compare with cert hash attribute in store)
                PKCS7_ISSUER_AND_SERIAL issuerAndSerial = {};
                issuerAndSerial.issuer = sk_X509_value(skCertFound, j)->cert_info->issuer;
                issuerAndSerial.serial = sk_X509_value(skCertFound, j)->cert_info->serialNumber;
            
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

                // add URL to the person
                NSMutableString *strCertURL = [[NSMutableString alloc] initWithCString:"cryptoarm://certificate/" encoding:NSASCIIStringEncoding];
                [strCertURL appendString:[NSString stringWithCString:[hexData cStringUsingEncoding:NSASCIIStringEncoding] encoding:NSASCIIStringEncoding]];
            
                ABMultiValueAddValueAndLabel(urlMultiValue, strCertURL, kABOtherLabel, NULL);
            }

            CFErrorRef *errorAddrBook;
            ABRecordSetValue(currentPerson, kABPersonURLProperty, urlMultiValue, errorAddrBook);
            CFRelease(urlMultiValue);
        
            // save changes to the address book
            CFErrorRef error = NULL;
            ABAddressBookSave(addressBook, &error);
            
            break;
        }
    }
    
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [allViewControllers removeObjectIdenticalTo:self];
    self.navigationController.viewControllers = allViewControllers;
    
    // reload parent tableView
    [(AdvancedAddressBookViewController*)[allViewControllers objectAtIndex:([allViewControllers count] - 1)] reloadTableView];
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

- (id<MenuDataRefreshinProtocol>)createSavingObject
{
    //TODO: implement, if necessary
    return nil;
}

#pragma mark - table view controller delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sk_X509_num(skCertFound); // number of certificates extracted from the url(bound to the person record)
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
        nib = [[NSBundle mainBundle] loadNibNamed:@"RecipientCertificateCellViewLandscape" owner:self options:nil];
        CellIdentifier = [NSString stringWithFormat:@"recipientCertificateCellViewLandscape %d %d", indexPath.section, indexPath.row];
    }
    else
    {
        nib = [[NSBundle mainBundle] loadNibNamed:@"RecipientCertificateCellViewPortrait" owner:self options:nil];
        CellIdentifier = [NSString stringWithFormat:@"recipientCertificateCellViewPortrait %d %d", indexPath.section, indexPath.row];
    }
    
    RecipientCertificateCellView *cell = (RecipientCertificateCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = (RecipientCertificateCellView *)[nib objectAtIndex:0];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // set cell info
        // add action to the button
        [cell.btnShowCert setTitle:[NSString stringWithFormat:@"%d", indexPath.row] forState:UIControlStateNormal];
        [cell.btnShowCert addTarget:self action:@selector(showCertificate:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.btnRemoveCert setTitle:[NSString stringWithFormat:@"%d", indexPath.row] forState:UIControlStateNormal];
        [cell.btnRemoveCert addTarget:self action:@selector(removeCertificate:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.imgCert performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:@"cert-valid.png"] waitUntilDone:YES];

        if ( sk_X509_num(skCertFound) )
        {
            // at first show the first cert in stack; TODO: store user's selected cert
            X509 *selectedCert = X509_new();
            selectedCert = sk_X509_value(skCertFound, indexPath.row);
            
            cell.cert = [[[CertificateInfo alloc] initWithX509:selectedCert] autorelease];
            [cell.imgCert performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:@"cert-valid.png"] waitUntilDone:YES];
            
            if (selectedCellCert && !X509_cmp(selectedCellCert, sk_X509_value(skCertFound, indexPath.row)))
            {
                // set selection(tick) if [tableView reloadData] was called by changing orientation of the device
                [cell.imgTick setImage:[UIImage imageNamed:@"ClosePanel.PNG"]];
            }
            
            // parsing X509
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

            X509_free(selectedCert);
        }
        else
        {
            // TODO: paste empty image(or nocert image) if cert url is absent
            // [cell.imgCert performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:@"cert-valid.png"] waitUntilDone:YES];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecipientCertificateCellView *cell = (RecipientCertificateCellView *)[tableView cellForRowAtIndexPath:indexPath];

    if (selectedCellCert == nil)
    {
        selectedCellCert = sk_X509_value(skCertFound, indexPath.row);
        
        if (cell != nil)
        {
            [cell.imgTick setImage:[UIImage imageNamed:@"ClosePanel.PNG"]];            
        }
    }
    else if (cell != nil)
    {
        // Configure the view for the selected state
        if (!X509_cmp(sk_X509_value(skCertFound, indexPath.row), selectedCellCert))
        {
            [cell.imgTick setImage:nil];
            selectedCellCert = nil;
        }
        else
        {
            [cell.imgTick setImage:[UIImage imageNamed:@"ClosePanel.PNG"]];

            for (CFIndex i = 0; i < sk_X509_num(skCertFound); i++)
            {
                if (!X509_cmp(sk_X509_value(skCertFound, i), selectedCellCert))
                {
                    // remove previously selected item
                    RecipientCertificateCellView *cellForRemoveTick = (RecipientCertificateCellView *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    [cellForRemoveTick.imgTick setImage:nil];
                    
                    break;
                }
            }
            
            // store selected cert
            selectedCellCert = sk_X509_value(skCertFound, indexPath.row);
        }
    }

    /* 
    imgCert.frame = CGRectMake(imgCert.frame.origin.x + 60, imgCert.frame.origin.y, imgCert.frame.size.width, imgCert.frame.size.height);
         lblSubject.frame = CGRectMake(lblSubject.frame.origin.x + 60, lblSubject.frame.origin.y, lblSubject.frame.size.width, lblSubject.frame.size.height);
         lblCertIssuer.frame = CGRectMake(lblCertIssuer.frame.origin.x + 60, lblCertIssuer.frame.origin.y, lblCertIssuer.frame.size.width, lblCertIssuer.frame.size.height);
         lblValidTo.frame = CGRectMake(lblValidTo.frame.origin.x + 60, lblValidTo.frame.origin.y, lblValidTo.frame.size.width, lblValidTo.frame.size.height);
         */
}

- (void)removeCertificate:(id)sender
{
    UIButton *button = sender;
    sk_X509_delete(skCertFound, [button.titleLabel.text intValue]);
  
    [tblRecipients reloadData];
}

- (void)showCertificate:(id)sender
{
    UIButton *button = sender;
    
    X509 *selectedCert = X509_new();
    selectedCert = sk_X509_value(skCertFound, [button.titleLabel.text intValue]);
    
    CertificateInfo *certInfo = [[CertificateInfo alloc] initWithX509:selectedCert];
    [parentController pushNavController:[[CertDetailViewController alloc] initWithCertInfo:certInfo]];
    
    X509_free(selectedCert);
}

- (void) addCertificate
{
    [parentController pushNavController:[[CertStoreViewController alloc] initWithNibName:@"CertStoreViewController" andPerson:selectedPerson bundle:nil]];
}

- (void)updateCertList:(STACK_OF(X509) *)skNewCertList
{
    skCertFound = skNewCertList;
    [tblRecipients reloadData];
}

@end
