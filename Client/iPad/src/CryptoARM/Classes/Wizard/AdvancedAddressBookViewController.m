//
//  AdvancedAddressBookViewController.m
//  CryptoARM
//
//  Created by Денис Бурдин on 06.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AdvancedAddressBookViewController.h"

@implementation AdvancedAddressBookViewController

@synthesize isShowingLandscapeView, tblRecipients, people, personCertificatesMenuPopover, rectCellBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //TODO: create chain view controller and insert to popover instead of tempController
        UIViewController* tempController = [[UIViewController alloc] init];
        groupsPopover = [[UIPopoverController alloc] initWithContentViewController:tempController];
        [tempController release];
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

    // initialize array of records in the address book
    ABAddressBookRef addressBook = ABAddressBookCreate();
    people = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    [people retain];
    
    tblRecipients.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tblRecipients.dataSource = self;
    tblRecipients.delegate = self;
    
    [tblRecipients reloadData];
    
    // add callback watch device orientation changed selector
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    isShowingLandscapeView = NO;
    
    // find out current device orientation
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        isShowingLandscapeView = YES;
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation))
    {
        isShowingLandscapeView = NO;
    }
}

- (void)viewDidUnload
{
    [self setIsShowingLandscapeView:nil];
    [self setTblRecipients:nil];
    [self setPeople:nil];
    [self setPersonCertificatesMenuPopover:nil];
    groupsButton = nil;
    saveButton = nil;
    
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
    [groupsPopover release];
    [tblRecipients release];
    [people release];
    [personCertificatesMenuPopover release];
    
    if ( groupsButton )
    {
        [groupsButton release];
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
    return @"AdvancedAddressBookViewController";
}

- (NSString*)itemTag
{
    return [AdvancedAddressBookViewController itemTag];
}

- (NSString*)title
{
    return NSLocalizedString(@"WIZARD_ADVANCED_ADDRESS_BOOK_TITLE", @"WIZARD_ADVANCED_ADDRESS_BOOK_TITLE");
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

    if ( !groupsButton )
    {
        UIButton *buttonWithImage = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonWithImage addTarget:self action:@selector(groupsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        buttonWithImage.frame = CGRectMake(0, 0, 42, 42);
        [buttonWithImage setImage:[UIImage imageNamed:@"chain.png"] forState:UIControlStateNormal];

        groupsButton = [[UIBarButtonItem alloc] initWithCustomView:buttonWithImage];
    }

    [arrAdditionalButtons addObject:groupsButton];
    [arrAdditionalButtons addObject:saveButton];
    
    return arrAdditionalButtons;
}

- (void)groupsButtonAction:(id)sender
{
    if( parentController )
    {
        [parentController dismissPopovers];
    }
    
    [groupsPopover presentPopoverFromBarButtonItem:groupsButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)saveButtonAction:(id)sender
{
    if ( parentController )
    {
        [parentController dismissPopovers];
    }
    
    // some error
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WARNING", @"WARNING") message:NSLocalizedString(@"UNKNOWN_ERROR_OCCURED", @"UNKNOWN_ERROR_OCCURED") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    [alert release];
}

- (void)setParentNavigationController:(UIViewController*)navController
{
    parentController = (DetailNavController*)navController;
}

- (BOOL)preserveController
{
    return FALSE;
}

- (void)dismissPopovers
{
    [groupsPopover dismissPopoverAnimated:YES];
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
    // return number of records in the address book
    return [people count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // extract cert url in the AddressBook person record
    ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    urlMultiValue = ABRecordCopyValue((ABRecordRef)[people objectAtIndex:indexPath.row], kABPersonURLProperty);
    
    STACK_OF(X509) *skCertFound = sk_X509_new_null();
    [Crypto getCertificatesFromURL:skCertFound withURLCertList:urlMultiValue andStore:@"AddressBook"];
    
    NSArray *nib;
    NSString *CellIdentifier;
    
    if (isShowingLandscapeView)
    {
        nib = [[NSBundle mainBundle] loadNibNamed:@"RecipientCellViewLandscape" owner:self options:nil];
        CellIdentifier = [NSString stringWithFormat:@"recipientCellLandscape %d %d", indexPath.section, indexPath.row];
    }
    else
    {
        nib = [[NSBundle mainBundle] loadNibNamed:@"RecipientCellViewPortrait" owner:self options:nil];
        CellIdentifier = [NSString stringWithFormat:@"recipientCellPortrait %d %d", indexPath.section, indexPath.row];
    }
    
    RecipientCellView *cell = (RecipientCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = (RecipientCellView *)[nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        // set cell info
        // add action to the button
        [cell.btnAddOrRemoveRecipient setTitle:[NSString stringWithFormat:@"%d", indexPath.row] forState:UIControlStateNormal];
        [cell.btnAddOrRemoveRecipient addTarget:self action:@selector(performSelectorOnCellButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // select all information from the record in address book
        if ( ABPersonHasImageData([people objectAtIndex:indexPath.row]) )
        {
            // extract user profile image
            CFDataRef userImage = ABPersonCopyImageData([people objectAtIndex:indexPath.row]);
            [cell.imgUser performSelectorOnMainThread:@selector(setImage:) withObject: [UIImage imageWithData:(NSData *)userImage] waitUntilDone:YES];
        }
        else
        {   // set empty image
            [cell.imgUser performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:@"cert-valid.png"] waitUntilDone:YES];
        }
        
        NSMutableString *strNumberOfBoundCertificates = [[NSMutableString alloc] initWithString:NSLocalizedString(@"WIZARD_CERTIFICATES", @"WIZARD_CERTIFICATES")];
        [strNumberOfBoundCertificates appendString:[NSString stringWithFormat:@" %d", sk_X509_num(skCertFound)]];
        [cell.lblNumberOfBoundCerts setText:strNumberOfBoundCertificates];
        [strNumberOfBoundCertificates release];

        // user initials
        NSMutableString *strUserInitials = [[NSMutableString alloc] init];
        
        if (ABRecordCopyValue([people objectAtIndex:indexPath.row], kABPersonLastNameProperty))
        {
            [strUserInitials appendString:[NSString stringWithString:ABRecordCopyValue([people objectAtIndex:indexPath.row], kABPersonLastNameProperty)]];
        }
        
        if (ABRecordCopyValue([people objectAtIndex:indexPath.row], kABPersonFirstNameProperty))
        {
            if ([strUserInitials length])
            {
                [strUserInitials appendString:@" "];
            }
            
            [strUserInitials appendString:[NSString stringWithString:ABRecordCopyValue([people objectAtIndex:indexPath.row], kABPersonFirstNameProperty)]];
        }

        if (ABRecordCopyValue([people objectAtIndex:indexPath.row], kABPersonMiddleNameProperty))
        {
            if ([strUserInitials length])
            {
                [strUserInitials appendString:@" "];
            }

            [strUserInitials appendString:[NSString stringWithString:ABRecordCopyValue([people objectAtIndex:indexPath.row], kABPersonMiddleNameProperty)]];
        }

        [cell.lblUserName setText:strUserInitials];
        [strUserInitials release];
        
        if ( sk_X509_num(skCertFound) )
        {
            // at first show the first cert in stack; TODO: store user's selected cert
            X509_INFO *selectedCert = X509_INFO_new();
            selectedCert->x509 = sk_X509_value(skCertFound, 0);
            
            cell.cert = [[[CertificateInfo alloc] initWithX509_INFO:selectedCert] autorelease];
            [cell.imgCert performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:@"cert-valid.png"] waitUntilDone:YES];
                
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
                        
            [cell.lblCertIssuer setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"CERT_WHO_ISSUED", @"CERT_WHO_ISSUED"), [Crypto getDNFromX509_NAME:cell.cert.issuer withNid:NID_commonName]]];
            
            [cell.lblValidTo setText:[NSString stringWithFormat:@"%@: %s %@ %s %@.", NSLocalizedString(@"CERT_EXPIRED", @"CERT_EXPIRED"), szDate, monthName, szYear, NSLocalizedString(@"YEAR_PREFIX", @"YEAR_PREFIX")]];
        }
        else
        {
            // TODO: paste empty image(or nocert image) if cert url is abscent
            // [cell.imgCert performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:@"cert-valid.png"] waitUntilDone:YES];
        }
        
        // add image to the remove user button
        [cell.btnAddOrRemoveRecipient setImage:[UIImage imageNamed:@"folder.png"] forState:UIControlStateNormal];
        rectCellBtn = cell.btnAddOrRemoveRecipient.frame; // store cell button frame size
    }

    sk_X509_free(skCertFound);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)performSelectorOnCellButton:(id)sender
{
    UIButton *button = sender;
    
    CGRect rectPopoverPlace = rectCellBtn;
    rectPopoverPlace.origin.y += [button.titleLabel.text intValue] * 78;

    // show popover
    ABRecordRef personRecord = (ABRecordRef)[people objectAtIndex:[button.titleLabel.text intValue]];
    
    ABMultiValueRef URLs = ABRecordCopyValue(personRecord, kABPersonURLProperty);
    ABMutableMultiValueRef personCertsURL = ABMultiValueCreateMutableCopy(URLs);

    CertListPopoverViewController *certListMenu = [[CertListPopoverViewController alloc] initWithCertListURL:personCertsURL];
    [certListMenu setTitle:NSLocalizedString(@"ENCIPHER_CERTIFICATE", @"ENCIPHER_CERTIFICATE")];

    UINavigationController *navSettingsMenu = [[UINavigationController alloc] initWithRootViewController:certListMenu];
    
    personCertificatesMenuPopover = [[UIPopoverController alloc] initWithContentViewController:navSettingsMenu];
    personCertificatesMenuPopover.popoverContentSize = CGSizeMake(personCertificatesMenuPopover.popoverContentSize.width, [certListMenu calculateMenuHeight]);

    [certListMenu setPersonCertificatesMenuPopover:personCertificatesMenuPopover]; // to dismiss this popover in the child class when cell cert item is selected
    [certListMenu setSelectedPerson:personRecord];
    [certListMenu release];
    
    [personCertificatesMenuPopover presentPopoverFromRect:rectPopoverPlace inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

@end
