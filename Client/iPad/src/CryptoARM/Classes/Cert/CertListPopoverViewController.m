//
//  CertListPopoverViewController.m
//  CryptoARM
//
//  Created by Денис Бурдин on 12.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CertListPopoverViewController.h"

@implementation CertListPopoverViewController
@synthesize menuTable, personCertificatesMenuPopover, selectedPerson, parentController;

- (id)initWithCertListURL:(ABMutableMultiValueRef)certListURL
{
    self = [super init];
    
    if (self)
    {
        m_certListURL = certListURL;
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
    skPersonCerts = sk_X509_new_null();

    menuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44) style:UITableViewStylePlain];
    
    menuTable.delegate = self;
    menuTable.dataSource = self;
    
    menuTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [menuTable reloadData];
    self.view = menuTable;
    
    if (m_certListURL)
    {
        // extract certificates bound to url in the AddressBook person record
        [Crypto getCertificatesFromURL:skPersonCerts withURLCertList:m_certListURL andStore:@"AddressBook"];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setPersonCertificatesMenuPopover:nil];
    [self setSelectedPerson:nil];
    [self setMenuTable:nil];
    [self setParentController:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (CGFloat)calculateMenuHeight
{
    return 57 * (sk_X509_num(skPersonCerts) + 1) + 35;
}

- (void)dealloc
{
    [menuTable release];
    [personCertificatesMenuPopover release];
    [parentController dealloc];
    
    if (skPersonCerts)
    {
        sk_X509_free(skPersonCerts);
    }
        
    [super dealloc];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return sk_X509_num(skPersonCerts) + 1; // also show 'add cert to person' button
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Person record bound cert %d %d", indexPath.section, indexPath.row];
    
    if (indexPath.row < sk_X509_num(skPersonCerts))
    {
        CertCellView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CertCellViewWithTick" owner:self options:nil];
            cell = (CertCellView *)[nib objectAtIndex:0];
        
            X509 *selectedCert = X509_new();
            selectedCert = sk_X509_value(skPersonCerts, indexPath.row);
        
            // parsing X509_INFO
            CertificateInfo *certInfo = [[CertificateInfo alloc] initWithX509:selectedCert];
            time_t validTo = certInfo.validTo; // cert expires date
        
            // set language from CryptoARM settings pane
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
            NSString* selectedLanguage = [languages objectAtIndex:0];
            NSString *localeIdentifier = @"en"; //default value
        
            if ([selectedLanguage isEqualToString:@"ru"])
            {
                localeIdentifier = @"ru_RU";
            }
            else if ([selectedLanguage isEqualToString:@"en"])
            {
                localeIdentifier = @"en_EN";
            }
        
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
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
        
            // set cell info
            [cell.certImageView performSelectorOnMainThread:@selector(setImage:) withObject: [UIImage imageNamed:@"cert-valid.png"] waitUntilDone:YES];        
            cell.certSubject.text = [Crypto getDNFromX509_NAME:certInfo.subject withNid:NID_commonName];
            cell.certIssuer.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"CERT_WHO_ISSUED", @"CERT_WHO_ISSUED"), [Crypto getDNFromX509_NAME:certInfo.issuer withNid:NID_commonName]];
            cell.certValidTo.text = [NSString stringWithFormat:@"%@: %s %@ %s %@.", NSLocalizedString(@"CERT_EXPIRED", @"CERT_EXPIRED"), szDate, monthName, szYear, NSLocalizedString(@"YEAR_PREFIX", @"YEAR_PREFIX")];
            
            // make first cert in the URL multi-string selected
            ABMultiValueRef URLs = ABRecordCopyValue(selectedPerson, kABPersonURLProperty);
            ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutableCopy(URLs);
                    
            // check the extracted url to find 'cryptoarm' prefix
            NSString *strSelectedURL = [NSString stringWithString:ABMultiValueCopyValueAtIndex(urlMultiValue, 0)];            
            NSString *strHash = [[NSString alloc] init];
            
            NSArray *arrUrlComponents = [strSelectedURL componentsSeparatedByString:@"/"];
            NSRange subStrRange = [[arrUrlComponents objectAtIndex:0] rangeOfString:@"cryptoarm"]; // this is the prefix for the application
            if (subStrRange.location != NSNotFound)
            {
                for (int i = 1; i < [arrUrlComponents count]; i++)
                {
                    if ([[arrUrlComponents objectAtIndex:i] isEqualToString:@"certificate"])
                    {
                        // certificate prefix was found in the recieved url string
                        strHash = [arrUrlComponents objectAtIndex:i+1];
                        break;
                    }
                }
            }
            
            if ([strHash length])
            {
                // create hash on it(to compare with cert hash attribute in store)
                PKCS7_ISSUER_AND_SERIAL issuerAndSerial = {};
                issuerAndSerial.issuer = selectedCert->cert_info->issuer;
                issuerAndSerial.serial = selectedCert->cert_info->serialNumber;
            
                unsigned char *szHash = (unsigned char *)malloc(256);
                unsigned char *szHashValue = (unsigned char *)malloc(256);
            
                szHash[0] = '\0';
                szHashValue[0] = '\0';
                unsigned int length = 0;
            
                if (PKCS7_ISSUER_AND_SERIAL_digest(&issuerAndSerial, EVP_sha1(), szHash, &length) <= 0)
                {
                    // TODO: throw error
                }
            
                NSString *hexData = [Utils hexDataToString:szHash length:length isNeedSpacing:NO];
            
                if ([hexData isEqualToString:strHash])
                {
                    [cell.imgTick performSelectorOnMainThread:@selector(setImage:) withObject: [UIImage imageNamed:@"ClosePanel.PNG"] waitUntilDone:YES];
                }
            }

            X509_free(selectedCert);
            [certInfo release];
        }
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            UILabel *lblAddCertFromStore = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 200, 37)];
            [lblAddCertFromStore setText:NSLocalizedString(@"ADD_CERTS_FROM_STORE", @"ADD_CERTS_FROM_STORE")];
            
            [cell addSubview:lblAddCertFromStore];
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < sk_X509_num(skPersonCerts))
    {
        ABAddressBookRef addressBook = ABAddressBookCreate();
        NSArray *people = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);

        for (CFIndex i = 0; i < [people count]; i++)
        {
            // find person by enumeration
            ABRecordID firstRecordID = ABRecordGetRecordID((ABRecordRef)[people objectAtIndex:i]);
            ABRecordID secondRecordID = ABRecordGetRecordID(selectedPerson);
            ABRecordRef currentPerson = (ABRecordRef)[people objectAtIndex:i];

            if (firstRecordID == secondRecordID)
            {
                // extract cert url in the AddressBook person record
                ABMultiValueRef URLs = ABRecordCopyValue(currentPerson, kABPersonURLProperty);
                ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutableCopy(URLs);

                // check the extracted url to find 'cryptoarm' prefix
                NSString *strSelectedURL = [NSString stringWithString:ABMultiValueCopyValueAtIndex(urlMultiValue, indexPath.row)];            

                // make selected certificate first in the address book person record URLMultistring to store it as active encryption cert
                ABMultiValueRemoveValueAndLabelAtIndex(urlMultiValue, indexPath.row);
                ABMultiValueInsertValueAndLabelAtIndex(urlMultiValue, strSelectedURL, kABOtherLabel, 0, NULL);

                CFErrorRef *errorAddrBook;
                ABRecordSetValue(currentPerson, kABPersonURLProperty, urlMultiValue, errorAddrBook);
                CFRelease(urlMultiValue);

                CFErrorRef error;
                ABAddressBookSave(addressBook, &error);
            
                break;
            }
        }
    }
    else
    {
        // show certificate bound manager
        [parentController pushNavController:[[AddressBookCertificateBindingManager alloc] initWithNibName:@"AddressBookCertificateBindingManager" andPerson:selectedPerson bundle:nil]];
    }
    
    [personCertificatesMenuPopover dismissPopoverAnimated:YES];
}

@end
