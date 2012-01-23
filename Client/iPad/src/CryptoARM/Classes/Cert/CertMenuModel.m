//
//  getDNFromX509_NAME.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CertMenuModel.h"

@implementation CertMenuModel

- (id) init
{
    self = [super init];

    static const char* szCerts =
    "-----BEGIN CERTIFICATE-----\n"
    "MIID0DCCA3+gAwIBAgIIbk1ypXYtYngwCAYGKoUDAgIDMIHCMRIwEAYIKoUDA4ED\n"
    "AQETBDQzNjUxGDAWBgkqhkiG9w0BCQEWCW1kNUBiay5ydTELMAkGA1UEBhMCUlUx\n"
    "GTAXBgNVBAgeEAQcBDAEQAQ4BDkAIAQtBDsxHTAbBgNVBAceFAQZBD4ESAQ6BDAE\n"
    "QAAtBB4EOwQwMTswOQYDVQQKHjIEHgQeBB4AIAAiBCYEOAREBEAEPgQyBEsENQAg\n"
    "BCIENQRFBD0EPgQ7BD4EMwQ4BDgAIjEOMAwGA1UEAxMFZGVuaXMwHhcNMTExMTA5\n"
    "MTQ1MTIwWhcNMTIxMTA5MTQ1MTIwWjCBwjESMBAGCCqFAwOBAwEBEwQ0MzY1MRgw\n"
    "FgYJKoZIhvcNAQkBFgltZDVAYmsucnUxCzAJBgNVBAYTAlJVMRkwFwYDVQQIHhAE\n"
    "HAQwBEAEOAQ5ACAELQQ7MR0wGwYDVQQHHhQEGQQ+BEgEOgQwBEAALQQeBDsEMDE7\n"
    "MDkGA1UECh4yBB4EHgQeACAAIgQmBDgERARABD4EMgRLBDUAIAQiBDUERQQ9BD4E\n"
    "OwQ+BDMEOAQ4ACIxDjAMBgNVBAMTBWRlbmlzMGMwHAYGKoUDAgITMBIGByqFAwIC\n"
    "JAAGByqFAwICHgEDQwAEQGRCNK7JiZR7cKF43K3Ysta1qbFCFtYo/Y/LRVe6+9Hi\n"
    "Zt/zyzFLCYRPJ3AhOLEKcRNvm46P4fa3M0xM/QgGdZmjggFTMIIBTzApBgNVHQ4E\n"
    "IgQgPMTIFCv4wraOvLGcjnadnWvw7af46iKBD08Xc9MlGxkwCwYDVR0PBAQDAgPY\n"
    "MA8GA1UdEwQIMAYBAf8CAQEwggECBgNVHSMEgfowgfeAIDzEyBQr+MK2jryxnI52\n"
    "nZ1r8O2n+OoigQ9PF3PTJRsZoYHIpIHFMIHCMRIwEAYIKoUDA4EDAQETBDQzNjUx\n"
    "GDAWBgkqhkiG9w0BCQEWCW1kNUBiay5ydTELMAkGA1UEBhMCUlUxGTAXBgNVBAge\n"
    "EAQcBDAEQAQ4BDkAIAQtBDsxHTAbBgNVBAceFAQZBD4ESAQ6BDAEQAAtBB4EOwQw\n"
    "MTswOQYDVQQKHjIEHgQeBB4AIAAiBCYEOAREBEAEPgQyBEsENQAgBCIENQRFBD0E\n"
    "PgQ7BD4EMwQ4BDgAIjEOMAwGA1UEAxMFZGVuaXOCCG5NcqV2LWJ4MAgGBiqFAwIC\n"
    "AwNBALpYC4i2EIz8fCizFyOz43B2qTDQAKzVR7F49kmXA2mF6ORma92mZ3Ik/0Ar\n"
    "nPswHhIpJIkOZ9zQT24TKitALBo=\n"
    "-----END CERTIFICATE-----\n"
    "-----BEGIN CERTIFICATE-----\n"
    "MIID0DCCA3+gAwIBAgIIbk1ypXYtYngwCAYGKoUDAgIDMIHCMRIwEAYIKoUDA4ED\n"
    "AQETBDQzNjUxGDAWBgkqhkiG9w0BCQEWCW1kNUBiay5ydTELMAkGA1UEBhMCUlUx\n"
    "GTAXBgNVBAgeEAQcBDAEQAQ4BDkAIAQtBDsxHTAbBgNVBAceFAQZBD4ESAQ6BDAE\n"
    "QAAtBB4EOwQwMTswOQYDVQQKHjIEHgQeBB4AIAAiBCYEOAREBEAEPgQyBEsENQAg\n"
    "BCIENQRFBD0EPgQ7BD4EMwQ4BDgAIjEOMAwGA1UEAxMFZGVuaXMwHhcNMTExMTA5\n"
    "MTQ1MTIwWhcNMTIxMTA5MTQ1MTIwWjCBwjESMBAGCCqFAwOBAwEBEwQ0MzY1MRgw\n"
    "FgYJKoZIhvcNAQkBFgltZDVAYmsucnUxCzAJBgNVBAYTAlJVMRkwFwYDVQQIHhAE\n"
    "HAQwBEAEOAQ5ACAELQQ7MR0wGwYDVQQHHhQEGQQ+BEgEOgQwBEAALQQeBDsEMDE7\n"
    "MDkGA1UECh4yBB4EHgQeACAAIgQmBDgERARABD4EMgRLBDUAIAQiBDUERQQ9BD4E\n"
    "OwQ+BDMEOAQ4ACIxDjAMBgNVBAMTBWRlbmlzMGMwHAYGKoUDAgITMBIGByqFAwIC\n"
    "JAAGByqFAwICHgEDQwAEQGRCNK7JiZR7cKF43K3Ysta1qbFCFtYo/Y/LRVe6+9Hi\n"
    "Zt/zyzFLCYRPJ3AhOLEKcRNvm46P4fa3M0xM/QgGdZmjggFTMIIBTzApBgNVHQ4E\n"
    "IgQgPMTIFCv4wraOvLGcjnadnWvw7af46iKBD08Xc9MlGxkwCwYDVR0PBAQDAgPY\n"
    "MA8GA1UdEwQIMAYBAf8CAQEwggECBgNVHSMEgfowgfeAIDzEyBQr+MK2jryxnI52\n"
    "nZ1r8O2n+OoigQ9PF3PTJRsZoYHIpIHFMIHCMRIwEAYIKoUDA4EDAQETBDQzNjUx\n"
    "GDAWBgkqhkiG9w0BCQEWCW1kNUBiay5ydTELMAkGA1UEBhMCUlUxGTAXBgNVBAge\n"
    "EAQcBDAEQAQ4BDkAIAQtBDsxHTAbBgNVBAceFAQZBD4ESAQ6BDAEQAAtBB4EOwQw\n"
    "MTswOQYDVQQKHjIEHgQeBB4AIAAiBCYEOAREBEAEPgQyBEsENQAgBCIENQRFBD0E\n"
    "PgQ7BD4EMwQ4BDgAIjEOMAwGA1UEAxMFZGVuaXOCCG5NcqV2LWJ4MAgGBiqFAwIC\n"
    "AwNBALpYC4i2EIz8fCizFyOz43B2qTDQAKzVR7F49kmXA2mF6ORma92mZ3Ik/0Ar\n"
    "nPswHhIpJIkOZ9zQT24TKitALBo=\n"
    "-----END CERTIFICATE-----\n"
    "-----BEGIN CERTIFICATE-----\n"                                                                                                                                                                                                                                                 
    "MIIFnTCCBUygAwIBAgIKSzaA5AAAAABZZTAIBgYqhQMCAgMwggEEMR4wHAYJKoZI\n"                                                                                                                                                                                                            
    "hvcNAQkBFg9jYUBza2Jrb250dXIucnUxCzAJBgNVBAYTAlJVMTMwMQYDVQQIDCo2\n"                                                                                                                                                                                                            
    "NiDQodCy0LXRgNC00LvQvtCy0YHQutCw0Y8g0L7QsdC70LDRgdGC0YwxITAfBgNV\n"                                                                                                                                                                                                            
    "BAcMGNCV0LrQsNGC0LXRgNC40L3QsdGD0YDQszEwMC4GA1UECwwn0KPQtNC+0YHR\n"                                                                                                                                                                                                            
    "gtC+0LLQtdGA0Y/RjtGJ0LjQuSDRhtC10L3RgtGAMS4wLAYDVQQKDCXQl9CQ0J4g\n"                                                                                                                                                                                                            
    "wqvQn9CkIMKr0KHQmtCRINCa0L7QvdGC0YPRgMK7MRswGQYDVQQDExJVQyBTS0Ig\n"                                                                                                                                                                                                            
    "S29udHVyIChHVCkwHhcNMTEwNTMwMDYxMzAwWhcNMTIwNTMwMDYxMzAwWjCCAYUx\n"                                                                                                                                                                                                            
    "IDAeBgkqhkiG9w0BCQEWEXN1cHBvcnRAZG9udGV4LnJ1MQswCQYDVQQGEwJSVTEs\n"                                                                                                                                                                                                            
    "MCoGA1UECAwj0KDQvtGB0YLQvtCy0YHQutCw0Y8g0L7QsdC70LDRgdGC0YwxEzAR\n"                                                                                                                                                                                                            
    "BgNVBAcMCtCo0LDRhdGC0YsxPDA6BgNVBAoMM9Ce0J7QniAi0KLQvtGA0LPQvtCy\n"                                                                                                                                                                                                            
    "0YvQuSDQlNC+0LwgItCU0L7QvS3QotC10LrRgdGCIjE7MDkGA1UEAwwy0JHRg9C9\n"                                                                                                                                                                                                            
    "0LjQvdCwINCi0LDRgtGM0Y/QvdCwINCT0YDQuNCz0L7RgNGM0LXQstC90LAxPjA8\n"                                                                                                                                                                                                            
    "BgkqhkiG9w0BCQIML0lOTj02MTU1MDUyNjIwL0tQUD02MTU1MDEwMDEvT0dSTj0x\n"                                                                                                                                                                                                            
    "MDM2MTU1MDA3NTY5MRkwFwYDVQQMDBDQtNC40YDQtdC60YLQvtGAMTswOQYDVQQE\n"                                                                                                                                                                                                            
    "DDLQkdGD0L3QuNC90LAg0KLQsNGC0YzRj9C90LAg0JPRgNC40LPQvtGA0YzQtdCy\n"                                                                                                                                                                                                            
    "0L3QsDBjMBwGBiqFAwICEzASBgcqhQMCAiQABgcqhQMCAh4BA0MABECqQcncI22P\n"                                                                                                                                                                                                            
    "QU3ppyaEnrkNK6GFD2OOkcOgPHGiWeRR24HUVM7m+68CGKXy92ZftgtiDnjlxv/t\n"                                                                                                                                                                                                            
    "rFzExwFUqtaVo4ICFzCCAhMwDgYDVR0PAQH/BAQDAgTwMGoGA1UdJQRjMGEGCCsG\n"                                                                                                                                                                                                            
    "AQUFBwMCBggrBgEFBQcDBAYHKoUDAgIiBgYHKoUDBgMBAQYHKoUDAwcFRgYIKoUD\n"                                                                                                                                                                                                            
    "BgMBAwEGCCqFAwYDAQIBBggqhQMGAwEEAQYIKoUDBgMBBAIGCCqFAwYDAQQDMBwG\n"                                                                                                                                                                                                            
    "A1UdEQQVMBOBEXN1cHBvcnRAZG9udGV4LnJ1MB0GA1UdDgQWBBRdjEifl5axVer7\n"                                                                                                                                                                                                            
    "eG++GBro/JsUBDAfBgNVHSMEGDAWgBQttS1GRNv9Ok1H9xwOpN14FMmwBTBuBgNV\n"                                                                                                                                                                                                            
    "HR8EZzBlMGOgYaBfhi1odHRwOi8vY2Euc2tia29udHVyLnJ1L2NkcC9rb250dXIt\n"                                                                                                                                                                                                            
    "Z3QtMjAxMC5jcmyGLmh0dHA6Ly9jZHAuc2tia29udHVyLnJ1L2NkcC9rb250dXIt\n"                                                                                                                                                                                                            
    "Z3QtMjAxMC5jcmwwgZkGCCsGAQUFBwEBBIGMMIGJMEIGCCsGAQUFBzAChjZodHRw\n"                                                                                                                                                                                                            
    "Oi8vY2Euc2tia29udHVyLnJ1L2NlcnRpZmljYXRlcy9rb250dXItZ3QtMjAxMC5j\n"                                                                                                                                                                                                            
    "cnQwQwYIKwYBBQUHMAKGN2h0dHA6Ly9jZHAuc2tia29udHVyLnJ1L2NlcnRpZmlj\n"                                                                                                                                                                                                            
    "YXRlcy9rb250dXItZ3QtMjAxMC5jcnQwKwYDVR0QBCQwIoAPMjAxMTA1MzAwNjEz\n"                                                                                                                                                                                                            
    "MDBagQ8yMDEyMDUyOTA2MDgwMFowCAYGKoUDAgIDA0EAM2ZYb+9SyRJL97bIekQZ\n"                                                                                                                                                                                                            
    "Uwjh+kKRmFSqkxpTjQTU8F7feDg6DmXH5EMhRTLCoE64QGgXOsV8x1TgkUvRuYaF\n"                                                                                                                                                                                                            
    "Xw==\n"                                                                                                                                                                                                                                                                        
    "-----END CERTIFICATE-----\n";                                                                                                                                                                                                                                          
    
  //  SSL_library_init();
  //  OpenSSL_add_all_algorithms();
    
    BIO *bioCerts = BIO_new_mem_buf((void*)szCerts, -1);
    certArray = (STACK_OF(X509_INFO) *)PEM_X509_INFO_read_bio(bioCerts, NULL, NULL, NULL);

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
    X509_INFO *selectedCert = sk_X509_INFO_value(certArray, index.row);
    CertificateInfo *certInfo = [[[CertificateInfo alloc] initWithX509_INFO:selectedCert] autorelease];
    
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

        X509_INFO *selectedCert = sk_X509_INFO_value(certArray, idx.row);
    
        // parsing X509_INFO
        CertificateInfo *certInfo = [[CertificateInfo alloc] initWithX509_INFO:selectedCert];
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
