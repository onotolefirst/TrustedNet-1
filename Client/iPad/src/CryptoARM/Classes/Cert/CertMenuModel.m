//
//  getDNFromX509_NAME.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CertMenuModel.h"

@implementation CertMenuModel

@synthesize store;
@synthesize certArray;

- (id) initWithStoreName:(NSString *)strStoreName
{
    self = [super init];

    if( self )
    {
        //TODO: use store type from parameter
        self.store = [[CertificateStore alloc] initWithStoreType:CST_MY];
        self.certArray = self.store.certificates;
    }
    
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
    if( self.certArray )
    {
        return self.certArray.count;
    }
    
    return 0;
}

- (CGFloat)cellHeight:(NSIndexPath *)indexPath
{
    return 57;
}

- (UIViewController<NavigationSource>*)getDetailControllerForElementAt:(NSIndexPath*)index
{
    return [[[CertDetailViewController alloc] initWithCertInfo:[self.certArray objectAtIndex:index.row]] autorelease];
}

- (UITableViewCell*)fillCell:(UITableViewCell *)cell atIndex:(NSIndexPath *)idx inTableView:(UITableView *)tableView
{
    NSString *MyIdentifier = [NSString stringWithFormat:@"certCellView %d %d", idx.section, idx.row];
    
    CertCellView *cellView = (CertCellView *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cellView == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CertCellView" owner:self options:nil];
        cellView = (CertCellView *)[nib objectAtIndex:0];

        // parsing X509_INFO
        CertificateInfo *certInfo = [self.certArray objectAtIndex:idx.row];
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
