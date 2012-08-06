//
//  CheckStatusDialogViewController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 18.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CheckStatusDialogViewController.h"

@implementation CheckStatusDialogViewController
@synthesize dialogTitleItem;

@synthesize certForVerifying;
@synthesize delegate;

- (id)initWithCertificate:(CertificateInfo*)cert
{
    self = [super init];
    if (self) {
        self.certForVerifying = cert;
        certCheckType = CCT_LOCAL_CRL_ONLY;
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
    // Do any additional setup after loading the view from its nib.
    
    self.dialogTitleItem.title = NSLocalizedString(@"CERT_CHECK_STATUS_DLG_TITLE", @"Проверка статуса сертификата");
}

- (void)viewDidUnload
{
    [self setDialogTitleItem:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cert verify type cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Configure the cell...
    switch (indexPath.row)
    {
        case 0:
        {
            cell.textLabel.text = @"Проверить по локальному CRL";
            if( !(CCT_ONLINE_CRL & certCheckType) )
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
            break;
            
        case 1:
        {
            cell.textLabel.text = @"Проверить по CRL, полученному из УЦ";
            if( CCT_ONLINE_CRL & certCheckType )
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            certCheckType &= ~CCT_ONLINE_CRL;
            break;
            
        case 1:
            certCheckType |= CCT_ONLINE_CRL;
            break;
            
        default:
            break;
    }
    
    [tableView reloadData];
}

#pragma mark - Actions

- (IBAction)actionForButtonCancel:(id)sender
{
    if( !self.delegate )
    {
        NSLog(@"Warning! Delegate for CheckStatusDialogViewController is not setted");
        return;
    }
    
    if( ![self.delegate conformsToProtocol:@protocol(CheckStatusDialogViewControllerDelegate)] )
    {
        NSLog(@"Warning! Delegate object for CheckStatusDialogViewController is not conforms to delegate protocol");
        return;
    }
    
    [self.delegate statusVerifying:NO withParameters:(int)certCheckType];
}

- (IBAction)actionForButtonDone:(id)sender
{
    if( !self.delegate )
    {
        NSLog(@"Warning! Delegate for CheckStatusDialogViewController is not setted");
        return;
    }
    
    if( ![self.delegate conformsToProtocol:@protocol(CheckStatusDialogViewControllerDelegate)] )
    {
        NSLog(@"Warning! Delegate object for CheckStatusDialogViewController is not conforms to delegate protocol");
        return;
    }
    
    [self.delegate statusVerifying:YES withParameters:(int)certCheckType];
}

- (void)dealloc {
    [dialogTitleItem release];
    [super dealloc];
}
@end
