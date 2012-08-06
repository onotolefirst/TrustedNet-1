//
//  CertChainViewController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 11.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CertChainViewController.h"

#include "Crypto.h"
#include <Openssl/ctiosrsa.h>
#include <Openssl/store.h>


@implementation CertChainViewController

@synthesize certChain;
@synthesize delegate;

- (id)initWithCertificate:(CertificateInfo*)cert
{
    self = [super init];
    if (self)
    {
        //self.startCert = cert;
        self.certChain = [self buildChainForCert:cert];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( self.certChain )
    {
        return self.certChain.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Chain-Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...

    //Find cert type
    int certType = (indexPath.row==0) ? 0 : CIP_WITH_CHAIN_CONNECTOR;

    {
        CertificateInfo *currentCert = [certChain objectAtIndex:0];
        NSData *keyId = currentCert.privateKeyId;
        
        if( keyId && keyId.length )
        {
            certType |= CIP_PERSONAL;
        }
    }

    if( !(certType & CIP_PERSONAL) )
    {
        if( indexPath.row == (certChain.count-1) )
        {
            certType |= CIP_OTHER;
        }
        else if( indexPath.row == 0 )
        {
            certType |= CIP_ROOT;
        }
        else
        {
            certType |= CIP_INTERMEDIATE;
        }
    }

    CertificateInfo *currentCert = [self.certChain objectAtIndex:indexPath.row];
    switch ([CertificateInfo simplifyedStatusByDetailedStatus:[currentCert verify]]) {
        case CSS_VALID:
            certType |= CIP_VALID;
            break;
            
        case CSS_INVALID:
            certType |= CIP_INVALID;
            break;
            
        case CSS_INSUFFICIENT_INFO:
            certType |= CIP_INSUFFICIENT_INFO;
            break;
            
        default:
            break;
    }
    
    cell.imageView.image = [self getImageForElementType:certType];

    cell.indentationLevel = indexPath.row;
    cell.indentationWidth = 40;
    
    cell.textLabel.text = [Crypto getDNFromX509_NAME:currentCert.subject withNid:NID_commonName];
    
    cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
    cell.detailTextLabel.numberOfLines = 2;
    
    NSString *issuerDescription = NSLocalizedString(@"CERT_WHO_ISSUED", @"Кем выдан");
    NSString *issuerValue = [Crypto getDNFromX509_NAME:currentCert.issuer withNid:NID_commonName];
    
    NSString *expireDate = [Utils formatDateForCertificateView:[NSDate dateWithTimeIntervalSince1970:currentCert.validTo]];
    NSString *expireDescription = NSLocalizedString(@"CERT_EXPIRED", @"Истекает");
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@\n%@: %@", issuerDescription, issuerValue, expireDescription, expireDate];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( indexPath.row == (self.certChain.count - 1) || !self.delegate )
    {
        return;
    }
    
    [self.delegate pushCert:[certChain objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - Utility functions

- (NSArray*)buildChainForCert:(CertificateInfo*)cert
{
    NSMutableArray *resultChain = [[NSMutableArray alloc] init];
    
    X509_LOOKUP_METHOD *m = NULL;
    X509_STORE_CTX ctx = {0};
    
    ENGINE *workingEngine = ENGINE_by_id(CTIOSRSA_ENGINE_ID);
    
    //TODO: Why macro not resolves by preprocessor?
    //if( workingEngine && (CTIOSRSA_ENGINE_get_x509_lookup_method(workingEngine, &m) <= 0) )
    if( workingEngine && (ENGINE_ctrl(workingEngine, 570+1, 0, &m, 0) <= 0) )
    {
        NSLog(@"Unable to get lookup method");
        return [resultChain autorelease];
    }
    
    X509_STORE *x509store = X509_STORE_new();
    if( !X509_STORE_add_lookup(x509store, m) )
    {
        NSLog(@"Unable to add lookup method into store");
        return [resultChain autorelease];
    }
    
    if( !X509_STORE_CTX_init(&ctx, x509store, cert.x509, NULL) )
    {
        NSLog(@"Unable to init store context");
        return [resultChain autorelease];
    }
    
    X509_verify_cert(&ctx);
    
    STACK_OF(X509) *chain = X509_STORE_CTX_get_chain(&ctx);
    
    CertificateInfo *tmpCert;
    while( chain && sk_X509_num(chain) )
    {
        tmpCert = [[CertificateInfo alloc] initWithX509:sk_X509_pop(chain) doNotCopy:YES];
        [resultChain addObject:tmpCert];
        [tmpCert release];
    }
    
    return [resultChain autorelease];
}

- (void)setPopoverContentSize:(UIPopoverController*)parentPopover
{
    [self.tableView sizeToFit];
    CGSize size = self.tableView.contentSize;
    parentPopover.popoverContentSize = size;
}

- (UIImage*)getImageForElementType:(int)elementType
{
    NSNumber *elementKey = [NSNumber numberWithInt:elementType];
    UIImage *resultImage = [indexedImages objectForKey:elementKey];
    
    if( resultImage )
    {
        return resultImage;
    }
    
    UIImage *chainElement = nil;
    UIImage *certImage = nil;
    
    if( elementType & CIP_PERSONAL )
    {
        if( elementType & CIP_VALID )
        {
            certImage = [UIImage imageNamed:@"cert-private-other.png"];
        }
        else if( elementType & CIP_INSUFFICIENT_INFO )
        {
            //TODO: add appropriate image for status "insufficient info"
            certImage = [UIImage imageNamed:@"cert-intermediate-invalid.png"];
        }
        else if( elementType & CIP_INVALID )
        {
            certImage = [UIImage imageNamed:@"cert-intermediate-invalid.png"];
        }
    }
    else if( elementType & CIP_OTHER )
    {
        //TODO: add images for other certificates statuses
        if( elementType & CIP_VALID )
        {
            certImage = [UIImage imageNamed:@"cert-valid.png"];
        }
    }
    else if( elementType & CIP_INTERMEDIATE )
    {
        if( elementType & CIP_VALID )
        {
            certImage = [UIImage imageNamed:@"cert-intermediate-valid.png"];
        }
    }
    else if( elementType & CIP_ROOT )
    {
        if( elementType & CIP_VALID )
        {
            certImage = [UIImage imageNamed:@"cert-root.png"];
        }
    }
    
    if( !certImage )
    {
        //TODO: add image with "insufficient info" status
        certImage = [UIImage imageNamed:@"cert-intermediate-invalid.png"];
    }
    
    if( CIP_WITH_CHAIN_CONNECTOR & elementType )
    {
        chainElement = [UIImage imageNamed:@"chain-element.png"];
    }
        
    resultImage = [Utils constructImageWithIcon:certImage andAccessoryIcon:chainElement];
    
    [indexedImages setObject:resultImage forKey:elementKey];
    return resultImage;
}

@end
