
#import "CertDetailViewController.h"

@implementation CertDetailViewController
@synthesize textColor, arrayOU, certInfo, autoresizingMask;

#pragma mark -
#pragma mark View lifecycle

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [textColor release];
    [arrayOU release];
    [certInfo release];
    [settingsMenu release];
    
    [chainPopover release];
    if( chainButton )
    {
        [chainButton release];
    }
    
    [super dealloc];
}	

- (id) initWithCertInfo:(CertificateInfo*) cert
{
    self = [super init];

    autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;

    certInfo = [[CertificateInfo alloc] initFromCopy:cert];

    // multiple OU values in cert dn
    arrayOU = [[NSArray alloc] initWithArray:[Crypto getMultipleDNFromX509_NAME:certInfo.issuer withNid:NID_organizationalUnitName]];

    [self constructSettingsMenu];

    //TODO: create chain view controller and insert to popover instead of tempController
    CertChainViewController* tempController = [[CertChainViewController alloc] initWithNibName:@"CertChainViewController" bundle:nil andCert:cert->x509];
    chainPopover = [[UIPopoverController alloc] initWithContentViewController:tempController];
    [tempController release];

    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    // set page text color;
    textColor = [UIColor colorWithRed:0.294 green:0.537 blue:0.816 alpha:1.000];
        
    UITableView *tblView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];   
    tblView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tblView.dataSource = self;
    tblView.delegate = self;
    
    UIView *viewCellHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,165)];
    UILabel* certTitleName = [[UILabel alloc] initWithFrame:CGRectMake(160,50,229,21)];
    
    // set cert title name
    [certTitleName setText:NSLocalizedString(@"CERT_TITLE", @"CERT_TITLE")];
    [certTitleName setFont:[UIFont systemFontOfSize:20]];
    [certTitleName setTextColor:textColor];
    [certTitleName setBackgroundColor:[UIColor clearColor]];
    [certTitleName sizeToFit];
    [certTitleName setAutoresizingMask:autoresizingMask];
    [viewCellHeader addSubview:certTitleName];
    
    // set UIImageView with certificate status picture
    UIImageView *imgCertStatus = [[UIImageView alloc] initWithFrame:CGRectMake(15,29,128,128)];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"cert-valid" ofType:@"png"];
    NSData *certImageData = [NSData dataWithContentsOfFile:filePath];
    [imgCertStatus setImage:[UIImage imageWithData:certImageData]];
    [viewCellHeader addSubview:imgCertStatus];

    // set  as viewable container for certificate status
    UIView *certStatusContainer = [[UIView alloc] initWithFrame:CGRectMake(160,96,563,44)];
    [certStatusContainer setAutoresizingMask:autoresizingMask | UIViewAutoresizingFlexibleWidth];
    [certStatusContainer setBackgroundColor:[UIColor whiteColor]];
    [certStatusContainer.layer setCornerRadius:9.0f];
    
    UIColor *colorBorder = [UIColor colorWithRed:0.603 green:0.603 blue:0.603 alpha:1.000];
    [certStatusContainer.layer setBorderColor:colorBorder.CGColor];
    [certStatusContainer.layer setBorderWidth:1.0f];
    
    UILabel *lblCertStatus = [[UILabel alloc] initWithFrame:CGRectMake(260,0,290,40)];
    [lblCertStatus setTextAlignment:UITextAlignmentRight];
    [lblCertStatus setText:NSLocalizedString(@"CERT_VALID", @"CERT_VALID")];
    [lblCertStatus setAutoresizingMask:autoresizingMask];
    [lblCertStatus setTextColor:textColor];
    [certStatusContainer addSubview:lblCertStatus];

    UILabel *lblCertStatusTitle = [[UILabel alloc] initWithFrame:CGRectMake(15,0,230,40)]; 
    [lblCertStatusTitle setText:NSLocalizedString(@"CERT_STATUS", @"CERT_STATUS")];
    [lblCertStatusTitle setAutoresizingMask:autoresizingMask];
    [lblCertStatusTitle setTextColor:textColor];
    [certStatusContainer addSubview:lblCertStatusTitle];
    
    // add view as header in the table view
    [viewCellHeader addSubview:certStatusContainer];
    
    [tblView setTableHeaderView:viewCellHeader];
    [tblView reloadData];

    self.view = tblView;
    
    [tblView release];
    [viewCellHeader release];
    [certTitleName release];
    [lblCertStatus release];
    [certStatusContainer release];
    [imgCertStatus release];
    [lblCertStatusTitle release];
}

- (void)viewDidUnload
{
    [self setTextColor:nil];
    [self setArrayOU:nil];
    [self setCertInfo:nil];
    
    settingsMenu = nil;
    chainButton = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // There are three sections, for date, genre, and characters, in that order.
    return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	/*
	 The number of rows varies by section.
	 */
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 3;
            break;
        case 1:
            rows = 3 + [arrayOU count];
            break;
        case 2:
            rows = 6;
            break;
        case 3:
            rows = 2;
            break;
        case 4:
            rows = 1 + [certInfo.eku count];
            break;
        case 5:
        case 6:
            rows = ([certInfo.akid length] ? 2 : 1);
            break;
        case 7:
            rows = 1 + [certInfo.cdpURLs count];
            break;
        case 8:
            rows = 1 + [certInfo.authorityInformationAccess count] * 2; // key - access method, value - URL
            break;
        default:
            break;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %d %d", indexPath.section, indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        // left section in the cell
        UILabel* cellName = [[UILabel alloc] initWithFrame:CGRectMake(0,14,150,30)];
        [cellName setFont:[UIFont systemFontOfSize:14]];
        [cellName setTextColor:[UIColor blackColor]];
        [cellName setAutoresizingMask:autoresizingMask];
    
        // right section in the cell
        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
        [cell.textLabel setTextColor:textColor];
        [cell.textLabel setTextAlignment:UITextAlignmentRight];

        // set not valid before and  not valid after strings
        //Not Valid After
        time_t validTo = certInfo.validTo;
        char szDate[5], szYear[5], szMonth[5], szHour[5], szMinute[5];
        szDate[0] = '\0'; szYear[0] = '\0', szMonth[0] = '\0', szHour[0] = '\0', szMinute[0] = '\0';
        strftime(szDate, 5, "%d", localtime(&validTo));
        strftime(szMonth, 5, "%m", localtime(&validTo));
        strftime(szYear, 5, "%Y", localtime(&validTo));    
        strftime(szHour, 5, "%H", localtime(&validTo));
        strftime(szMinute, 5, "%M", localtime(&validTo));
        NSString *notValidAfter = [NSString stringWithFormat:@"%s.%s.%s %s:%s", szDate, szMonth, szYear, szHour, szMinute];
        
        //Not Valid Before
        time_t validFrom = certInfo.validFrom;
        szDate[0] = '\0'; szYear[0] = '\0', szMonth[0] = '\0', szHour[0] = '\0', szMinute[0] = '\0';
        strftime(szDate, 5, "%d", localtime(&validFrom));
        strftime(szMonth, 5, "%m", localtime(&validFrom));
        strftime(szYear, 5, "%Y", localtime(&validFrom));
        strftime(szHour, 5, "%H", localtime(&validFrom));
        strftime(szMinute, 5, "%M", localtime(&validFrom));
        NSString *notValidBefore = [NSString stringWithFormat:@"%s.%s.%s %s:%s", szDate, szMonth, szYear, szHour, szMinute];
        
        // Set the text in the cell for the section/row.
        NSString *cellText = @"";
        NSString *cellNameText = @"";
    
        switch (indexPath.section) {
            case 0:
                // theme section
                switch (indexPath.row)
                {
                    case 0:
                        cellNameText = NSLocalizedString(@"CERT_C_TITLE", @"CERT_C_TITLE");
                        cellText = [Crypto getDNFromX509_NAME:certInfo.subject withNid:NID_countryName];
                        break;
                    case 1:
                        cellNameText = NSLocalizedString(@"CERT_CN_TITLE", @"CERT_CN_TITLE");
                        cellText = [Crypto getDNFromX509_NAME:certInfo.subject withNid:NID_commonName];
                        break;
                    case 2:
                        cellNameText = NSLocalizedString(@"CERT_E_TITLE", @"CERT_E_TITLE");
                        cellText = [Crypto getDNFromX509_NAME:certInfo.subject withNid:NID_pkcs9_emailAddress];
                        break;
                }
                break;
            case 1:
                // Issuer section
                switch (indexPath.row)
                {
                    case 0:
                        cellNameText = NSLocalizedString(@"CERT_CN_TITLE", @"CERT_CN_TITLE");
                        cellText = [Crypto getDNFromX509_NAME:certInfo.issuer withNid:NID_commonName];
                        break;
                    case 1:
                        cellNameText = NSLocalizedString(@"CERT_VERSION_TITLE", @"CERT_VERSION_TITLE");
                        cellText = certInfo.version;
                        break;
                    case 2:
                        cellNameText = NSLocalizedString(@"CERT_SN_TITLE", @"CERT_SN_TITLE");
                        cellText = certInfo.serialNumber;
                        break;
                    default:
                        if ([arrayOU count] > 0)
                        {
                            cellNameText = NSLocalizedString(@"CERT_OU_TITLE", @"CERT_OU_TITLE");
                            cellText = [arrayOU objectAtIndex:(indexPath.row - 3)];
                        }
                        break;
                }
                break;
            case 2:
                // Signature algorithm section
                switch (indexPath.row)
                {
                    case 0:
                        cellNameText = NSLocalizedString(@"CERT_SIGNATURE_ALG_TITLE", @"CERT_SIGNATURE_ALG_TITLE");
                        cellText = certInfo.signatureAlg;
                        break;
                    case 1:
                        cellNameText = NSLocalizedString(@"CERT_PARAMS_TITLE", @"CERT_PARAMS_TITLE");
                        cellText = certInfo.signatureParam;
                        break;
                    case 2:
                        cellNameText = NSLocalizedString(@"CERT_PUBLIC_KEY_TITLE", @"CERT_PUBLIC_KEY_TITLE");
                        cellText = certInfo.publicKey;
                        break;
                    case 3:
                        cellNameText = NSLocalizedString(@"CERT_SIGNATURE_TITLE", @"CERT_SIGNATURE_TITLE");
                        cellText = certInfo.signature;
                        break;
                    case 4:
                        cellNameText = NSLocalizedString(@"CERT_NOT_VALID_BEFORE_TITLE", @"CERT_NOT_VALID_BEFORE_TITLE");
                        cellText = notValidBefore;
                        break;
                    case 5:
                        cellNameText = NSLocalizedString(@"CERT_NOT_VALID_AFTER_TITLE", @"CERT_NOT_VALID_AFTER_TITLE");
                        cellText = notValidAfter;
                        break;
                }
                break;
            case 3:
                // Key usage section
                switch (indexPath.row)
                {
                    case 0:
                        cellNameText = NSLocalizedString(@"CERT_CRITICAL_TITLE", @"CERT_CRITICAL_TITLE");
                        cellText = (certInfo.isKeyUsageCritical ? NSLocalizedString(@"YES", @"YES") : NSLocalizedString(@"NO", @"NO"));
                        break;
                    case 1:
                        cellNameText = NSLocalizedString(@"CERT_USAGE_TITLE", @"CERT_USAGE_TITLE");
                        cellText = certInfo.keyUsageString;
                        break;                
                }
                break;
            case 4:
                // Extended Key Usage section
                switch (indexPath.row)
                {
                    case 0:
                        cellNameText = NSLocalizedString(@"CERT_CRITICAL_TITLE", @"CERT_CRITICAL_TITLE");
                        cellText = (certInfo.isEKUCritical ? NSLocalizedString(@"YES", @"YES") : NSLocalizedString(@"NO", @"NO"));
                        break;
                    default:
                        cellNameText = NSLocalizedString(@"CERT_PURPOSE_TITLE", @"CERT_PURPOSE_TITLE");
                        cellText = [certInfo.eku objectAtIndex:(indexPath.row-1)];
                        break;                        
                }
                break;
            case 5:
                // SKID section
                switch (indexPath.row)
                {
                    case 0:
                        cellNameText = NSLocalizedString(@"CERT_CRITICAL_TITLE", @"CERT_CRITICAL_TITLE");
                        cellText = (certInfo.isSKIDCritical ? NSLocalizedString(@"YES", @"YES") : NSLocalizedString(@"NO", @"NO"));
                        break;
                    case 1:
                        cellNameText = NSLocalizedString(@"CERT_KID_TITLE", @"CERT_KID_TITLE");
                        cellText = certInfo.skid;
                        break;
                }
                break;
            case 6:
                // AKID section
                switch (indexPath.row)
                {
                    case 0:
                        cellNameText = NSLocalizedString(@"CERT_CRITICAL_TITLE", @"CERT_CRITICAL_TITLE");
                        cellText = (certInfo.isAKIDCritical ? NSLocalizedString(@"YES", @"YES") : NSLocalizedString(@"NO", @"NO"));
                        break;
                    case 1:
                        cellNameText = NSLocalizedString(@"CERT_KID_TITLE", @"CERT_KID_TITLE");
                        cellText = certInfo.akid;
                        break;
                }
                break;
            case 7:
                // CDP section
                switch (indexPath.row)
                {
                    case 0:
                        cellNameText = NSLocalizedString(@"CERT_CRITICAL_TITLE", @"CERT_CRITICAL_TITLE");
                        cellText = (certInfo.isCDPCritical ? NSLocalizedString(@"YES", @"YES") : NSLocalizedString(@"NO", @"NO"));
                        break;
                    default:
                        cellNameText = NSLocalizedString(@"CERT_URL_TITLE", @"CERT_URL_TITLE");
                        cellText = [certInfo.cdpURLs objectAtIndex:(indexPath.row-1)];
                        break;
                }
                break;
            case 8:
                // Authority access section
                switch (indexPath.row)
                {
                    case 0:
                        cellNameText = NSLocalizedString(@"CERT_CRITICAL_TITLE", @"CERT_CRITICAL_TITLE");
                        cellText = (certInfo.isAuthorityAccessInfoCritical ? NSLocalizedString(@"YES", @"YES") : NSLocalizedString(@"NO", @"NO"));
                        break;
                    default:
                        if ( (indexPath.row % 2) != 0 )
                        {
                            // odd value - access method
                            cellNameText = NSLocalizedString(@"CERT_ACCESS_TITLE", @"CERT_ACCESS_TITLE");
                            cellText = [[certInfo.authorityInformationAccess allKeys] objectAtIndex:(indexPath.row / 2)];
                        }
                        else
                        {
                            // even value - URL
                            cellNameText = NSLocalizedString(@"CERT_URL_TITLE", @"CERT_URL_TITLE");
                            cellText = [certInfo.authorityInformationAccess valueForKey:
                                        [[certInfo.authorityInformationAccess allKeys] objectAtIndex:(indexPath.row / 2 - 1)]];
                        }
                        break;              
                }
                break;    
            default:
                break;
        }

        [cellName setText:[@"              " stringByAppendingString:cellNameText]];
        [cellName setBackgroundColor:[UIColor clearColor]];
        [cellName sizeToFit];
        
        UIView *cellNameView = [[UIView alloc] initWithFrame:cellName.frame];
        [cellNameView addSubview:cellName];
        [cellNameView sizeToFit];
        [cellNameView setFrame:CGRectMake(0, 0, cellNameView.frame.size.width, cellNameView.frame.size.height)];
        
        [cell addSubview:cellNameView];
        [cell.textLabel setText:cellText];

        // redraw cell text to correct fit
        cell.indentationLevel = cellName.frame.size.width;
        cell.indentationWidth = 1.3334f;

        [cellNameView release];
        [cellName release];
    }

    return cell;
}

#pragma mark - Section header titles

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = nil;
    switch (section) {
        case 0:
            title = NSLocalizedString(@"CERT_THEME", @"Theme section title");
            break;
        case 1:
            title = NSLocalizedString(@"CERT_ISSUER_NAME", @"Issuer section title");
            break;
        case 2:
            title = NSLocalizedString(@"CERT_SIGNATURE_ALG", @"Signature algorithm section title");
            break;
        case 3:
            title = NSLocalizedString(@"CERT_KEY_USAGE", @"Usage section title");
            break;
        case 4:
            title = NSLocalizedString(@"CERT_EXTENDED_KEY_USAGE", @"EKU section title");
            break;
        case 5:
            title = NSLocalizedString(@"CERT_SUBJECT", @"Subject section title");
            break;
        case 6:
            title = NSLocalizedString(@"CERT_AKID", @"Authority key identifier section title");
            break;
        case 7:
            title = NSLocalizedString(@"CERT_CDP", @"CRL distribution points section title");
            break;
        case 8:
            title = NSLocalizedString(@"CERT_AUTHORITY", @"Authority information access section title");
            break;
        default:
            break;
    }
    return title;
}

#pragma mark - NavigationSource protocol support

+ (NSString*)itemTag
{
    return @"CertDetailViewController";
}

- (NSString*)itemTag
{
    return [CertDetailViewController itemTag];
}

- (NSString*)title
{
    return [Crypto getDNFromX509_NAME:certInfo.subject withNid:NID_commonName];
}

- (NSArray*)getAdditionalButtons
{
    if( !chainButton )
    {
        UIButton *buttonWithImage = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonWithImage addTarget:self action:@selector(chainButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        buttonWithImage.frame = CGRectMake(0, 0, 42, 42);
        [buttonWithImage setImage:[UIImage imageNamed:@"chain.png"] forState:UIControlStateNormal];

        chainButton = [[UIBarButtonItem alloc] initWithCustomView:buttonWithImage];
    }
    
    return [NSArray arrayWithObject:chainButton];
}

- (void)chainButtonAction:(id)sender
{
    if( parentController )
    {
        [parentController dismissPopovers];
    }
    
    [chainPopover presentPopoverFromBarButtonItem:chainButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)setParentNavigationController:(UIViewController*)navController
{
    parentController = (DetailNavController*)navController;
}

- (BOOL)preserveController
{
    return FALSE;
}

- (SettingsMenuSource*)settingsMenu
{
    return settingsMenu;
}

- (void)constructSettingsMenu
{
    if( settingsMenu )
    {
        return;
    }
    
    settingsMenu = [[SettingsMenuSource alloc] initWithTitle:NSLocalizedString(@"CERT_MANAGE_CERTIFICATE", @"Управление сертификатом")];
    
    NSString *strVal = NSLocalizedString(@"CERT_CHECK_CERT_STATUS", @"Проверить статус");
    [settingsMenu addMenuItem:strVal withAction:nil forTarget:nil];
    [settingsMenu addMenuItem:NSLocalizedString(@"CERT_EXPORT_CERTIFICATE", @"Экспорт сертификата") withAction:nil forTarget:nil];
    [settingsMenu addMenuItem:NSLocalizedString(@"CERT_SEND_CERT_BY_EMAIL", @"Отправить по E-Mail") withAction:nil forTarget:nil];
    [settingsMenu addMenuItem:NSLocalizedString(@"CERT_PRINT_CERTIFICATE", @"Печать сертификата") withAction:nil forTarget:nil];
    [settingsMenu addMenuItem:NSLocalizedString(@"CERT_DELETE_CERTIFICATE", @"Удалить сертификат") withAction:nil forTarget:nil];
}

- (void)dismissPopovers
{
    [chainPopover dismissPopoverAnimated:YES];
}

- (Class)getSavingObjcetClass
{
    //TODO: implement, if necessary
    return [self class];
}

- (id<MenuDataRefreshinProtocol>*)createSavingObject
{
    //TODO: implement, if necessary
    return nil;
}

@end
