//
//  getDNFromX509_NAME.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CertMenuModel.h"

@implementation CertMenuModel

- (id) initWithStoreName:(NSString *)strStoreName
{
    self = [super init];
    certArray = sk_X509_new_null();

    // create temporary certificate binding to the address book store record
    ENGINE *e = ENGINE_by_id(CTIOSRSA_ENGINE_ID);
    STORE *store = STORE_new_engine(e);
    
    STORE_ctrl(store, CTIOSRSA_STORE_CTRL_SET_NAME, 0, strStoreName, NULL);
    
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
                sk_X509_push(certArray, cert);
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
    
    STORE_free(store);
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (UITableViewCellAccessoryType)typeOfElementAt:(NSIndexPath*)idx
{
    return UITableViewCellAccessoryDetailDisclosureButton;
}

- (NSString*)menuTitle
{
    return NSLocalizedString(@"MM_PRIVATE_CERTIFICATES", @"Private certificates");
}

- (NSInteger)mainMenuSections
{
    return 1;
}

- (NSInteger)mainMenuRowsInSection:(NSInteger)section{
    if (nil != certArray)
    {
        return certArray->stack.num;
    }
    else
    {
        return 0;
    }
}

- (CGFloat)cellHeight:(NSIndexPath *)indexPath
{
    return 57;
}

- (UIViewController<NavigationSource>*)getDetailControllerForElementAt:(NSIndexPath*)index
{
    X509 *selectedCert = sk_X509_value(certArray, index.row);
    CertificateInfo *certInfo = [[[CertificateInfo alloc] initWithX509:selectedCert] autorelease];
    
    return [[[CertDetailViewController alloc] initWithCertInfo:certInfo] autorelease];
}

- (UITableViewCell*)fillCell:(UITableViewCell *)cell atIndex:(NSIndexPath *)idx inTableView:(UITableView *)tableView
{
    NSString *MyIdentifier = [NSString stringWithFormat:@"certCellView %d %d", idx.section, idx.row];
    
    CertCellView *cellView = (CertCellView *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cellView == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CertCellView" owner:self options:nil];
        cellView = (CertCellView *)[nib objectAtIndex:0];

        X509 *selectedCert = sk_X509_value(certArray, idx.row);
    
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
        [cellView.certImageView performSelectorOnMainThread:@selector(setImage:) withObject: [UIImage imageNamed:@"cert-valid.png"] waitUntilDone:YES];        
        cellView.certSubject.text = [Crypto getDNFromX509_NAME:certInfo.subject withNid:NID_commonName];
        cellView.certIssuer.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"CERT_WHO_ISSUED",
                            @"CERT_WHO_ISSUED"), [Crypto getDNFromX509_NAME:certInfo.issuer withNid:NID_commonName]];
        cellView.certValidTo.text = [NSString stringWithFormat:@"%@: %s %@ %s %@.", NSLocalizedString(@"CERT_EXPIRED", @"CERT_EXPIRED"), szDate, monthName, szYear, NSLocalizedString(@"YEAR_PREFIX", @"YEAR_PREFIX")];
        [cellView setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

        [certInfo release];
    }

    return cellView;
}

//- (CommonNavigationItem*)submenuNavigationItemForIndex:(NSIndexPath *)indexPath
//{
//    return (CommonNavigationItem *)self;
//}

@end
