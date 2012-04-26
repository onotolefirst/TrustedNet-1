//
//  getDNFromX509_NAME.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CertMenuModel.h"

#include "openssl/pkcs12.h"

@implementation CertMenuModel

@synthesize store;
@synthesize certArray;

- (id) initWithStoreType:(enum CERT_STORE_TYPE)initType
{
    self = [super init];

    if( self )
    {
        store = [[CertificateStore alloc] initWithStoreType:initType];
        self.certArray = self.store.certificates;
    }
    
    return self;
}

- (id) initWithStore:(CertificateStore*)newStore
{
    self = [super init];
    
    if( self )
    {
        self.store = newStore;
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
    switch (store.storeType) {
        case CST_MY:
            return NSLocalizedString(@"MM_PRIVATE_CERTIFICATES", @"Private certificates");
            break;
            
        case CST_ADDRESS_BOOK:
            return NSLocalizedString(@"MM_OTHER_PEOPLE_CERTIFICATES", @"MM_OTHER_PEOPLE_CERTIFICATES");
            break;
            
        case CST_CA:
            return NSLocalizedString(@"MM_INTERMEDAITE_CERTIFICATION_AUTHORITIES", @"MM_INTERMEDAITE_CERTIFICATION_AUTHORITIES");
            break;
            
        case CST_ROOT:
            return NSLocalizedString(@"MM_TRUSTED_ROOT_CERTIFICATION_AUTHORITIES", @"MM_TRUSTED_ROOT_CERTIFICATION_AUTHORITIES");
            break;
            
        default:
            break;
    }
    
    return @"Unknown store type";
}

- (NSInteger)mainMenuSections
{
    return 1;
}

- (NSInteger)mainMenuRowsInSection:(NSInteger)section {
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
    CertDetailViewController *certDetail = [[CertDetailViewController alloc] initWithCertInfo:[self.certArray objectAtIndex:index.row]];
    certDetail.parentStore = self.store;
    
    return [certDetail autorelease];
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
        
        // set cell info
        
        switch ([CertificateInfo simplifyedStatusByDetailedStatus:[certInfo verify]]) {
            case CSS_VALID:
                cellView.certImageView.image = [UIImage imageNamed:@"cert-valid.png"];
                break;
                
            case CSS_INVALID:
                cellView.certImageView.image = [UIImage imageNamed:@"cert-invalid.png"];
                break;
                
            case CSS_INSUFFICIENT_INFO:
            default:
                cellView.certImageView.image = [UIImage imageNamed:@"cert-invalid.png"];
                break;
        }
        
        
        cellView.certSubject.text = [Crypto getDNFromX509_NAME:certInfo.subject withNid:NID_commonName];
        cellView.certIssuer.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"CERT_WHO_ISSUED",
                            @"CERT_WHO_ISSUED"), [Crypto getDNFromX509_NAME:certInfo.issuer withNid:NID_commonName]];
        cellView.certValidTo.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"CERT_EXPIRED", @"CERT_EXPIRED"), [Utils formatDateForCertificateView:[NSDate dateWithTimeIntervalSince1970:certInfo.validTo]]];
        [cellView setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }

    return cellView;
}

//- (CommonNavigationItem*)submenuNavigationItemForIndex:(NSIndexPath *)indexPath
//{
//    return (CommonNavigationItem *)self;
//}

#pragma mark - MenuDataRefreshinProtocol

- (void)addElement:(id)newElement
{
    if( ![newElement isKindOfClass:[CertificateInfo class]] )
    {
        NSLog(@"Wrong class transmitted");
        return;
    }
    
    //TODO: implement
}

- (void)removeElement:(id)removingElement
{
    if( [removingElement isKindOfClass:[CertificateInfo class]] )
    {
        [self.store removeCertificate:((CertificateInfo*)removingElement).x509];
        self.certArray = self.store.certificates;
        
        return;
    }
    else if( [removingElement isKindOfClass:[NSData class]] || [removingElement isKindOfClass:[NSMutableData class]] )
    {
        [self.store removePrivateKeyById:removingElement];
        
        return;
    }
    
    NSLog(@"Wrong class transmitted");
    return;
}

- (void)saveExistingElement:(id)savingElement
{
    if( ![savingElement isKindOfClass:[CertificateInfo class]] )
    {
        NSLog(@"Wrong class transmitted");
        return;
    }
    
    //TODO: implement
}

- (BOOL)checkIfExisting:(id)checkingElement
{
    //TODO: implement
    return YES;
}

@end
