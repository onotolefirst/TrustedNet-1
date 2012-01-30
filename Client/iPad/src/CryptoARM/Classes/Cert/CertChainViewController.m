//
//  CertChainViewController.m
//  CryptoARM
//
//  Created by Денис Бурдин on 20.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CertChainViewController.h"

@implementation CertChainViewController
@synthesize menuTable, chainMenuPopover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andCert:(X509 *)someCert
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        cert = someCert;
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
	X509_STORE *x509store = X509_STORE_new();
	X509_LOOKUP_METHOD *m = NULL;
	X509_STORE_CTX ctx = {NULL};
    ENGINE *g_e = ENGINE_by_id(CTIOSRSA_ENGINE_ID);

	if (!ENGINE_ctrl(g_e, CTIOSRSA_ENGINE_CTRL_GET_X509_LOOKUP_METHOD, 0, &m, 0) <= 0)
	{
        if (X509_STORE_add_lookup(x509store, m))
        {
            if (X509_STORE_CTX_init(&ctx, x509store, cert, NULL))
            {
                if (X509_verify_cert(&ctx) <= 0)
                {
                    // int iCode = X509_STORE_CTX_get_error(&ctx);
                    // BIO_printf(g_bioErr, "Certificate verification failed (code = %d '%s')\n",
                    //         iCode, X509_verify_cert_error_string(iCode));
                }

                stCertChain = X509_STORE_CTX_get_chain(&ctx);
                X509_STORE_CTX_cleanup(&ctx);
            }
            else
            {
                // Initializing store context failed
            }
        }
        else
        {
            // ERROR!
        }
    }
    else
    {
        // Allocating x509store failed
    }

    menuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44) style:UITableViewStylePlain];
    
    menuTable.delegate = self;
    menuTable.dataSource = self;
    
    menuTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [menuTable reloadData];
    self.view = menuTable;
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self setMenuTable:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (CGFloat)calculateMenuHeight
{
    return 60 * ([menuTable numberOfRowsInSection:0]) + 35;
}

- (void)dealloc
{
    [menuTable release];
    
    if (chainMenuPopover)
    {
        [chainMenuPopover dismissPopoverAnimated:YES];
    }
    
    [super dealloc];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return sk_X509_num(stCertChain);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cert chain cell %d %d", indexPath.section, indexPath.row];
    
    CertCellView *cellView = (CertCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cellView == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CertCellView" owner:self options:nil];
        cellView = (CertCellView *)[nib objectAtIndex:0];
        
        X509 *selectedCert = sk_X509_value(stCertChain, indexPath.row);
        
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [chainMenuPopover dismissPopoverAnimated:YES];
}

- (void)setPopoverController:(UIPopoverController *)controller
{
    chainMenuPopover = controller;
}

@end
