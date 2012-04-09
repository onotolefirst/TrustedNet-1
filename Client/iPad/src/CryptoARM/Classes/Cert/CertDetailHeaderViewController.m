//
//  CertDetailHeaderViewController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 02.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CertDetailHeaderViewController.h"

@implementation CertDetailHeaderViewController
@synthesize statusImage;
@synthesize headerTable;
@synthesize cert;
@synthesize store;
@synthesize keyIdentifier;

- (id)initWithCert:(CertificateInfo*)certForInit
{
    self = [super init];
    if (self) {
        if( certForInit )
        {
            cert = [certForInit retain];
        }
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
    
    self.headerTable.dataSource = self;
    self.headerTable.delegate = self;
    
    // View tweaks for older iOS versions
    if( [[UIDevice currentDevice].systemVersion compare:@"5.0"] == NSOrderedAscending )
    {
        self.headerTable.backgroundView = nil;
        self.headerTable.backgroundColor = [UIColor colorWithRed:(CGFloat)217/255 green:(CGFloat)219/255 blue:(CGFloat)225/255 alpha:1];
        self.statusImage.backgroundColor = [UIColor colorWithRed:(CGFloat)217/255 green:(CGFloat)219/255 blue:(CGFloat)225/255 alpha:1];
    }
    else
    {
        self.headerTable.backgroundView = nil;
    }
    
    //Draw certificate status image
    switch ([self getCertStatus]) {
        case 0:
            self.statusImage.image = [UIImage imageNamed:@"cert-valid.png"];
            break;
            
        default:
            break;
    }
    
    // Certificate private key displaying
    // TODO: create interface for private key?
    int idLength = 0;
    unsigned char *keyIdData = X509_keyid_get0(self.cert.x509, &idLength);
    if( keyIdData )
    {
        if( !self.store )
        {
            CertificateStore *tmpStore = [[CertificateStore alloc] initWithStoreType:CST_MY];
            self.store = tmpStore;
            [tmpStore release];
        }
        
        OPENSSL_ITEM params[] = {{STORE_PARAM_KEY_NO_PARAMETERS}};
        OPENSSL_ITEM attrs[2] = {0};
        
        attrs[0].code = STORE_ATTR_KEYID;
        attrs[0].value = (void*)keyIdData;
        attrs[0].value_size = idLength;
        attrs[1].code = STORE_ATTR_END;
        
        EVP_PKEY *keyFromStore = STORE_get_private_key(self.store.store, attrs, params);
        
        EVP_PKEY_CTX *keyContext = NULL;
        if( keyFromStore )
        {
            keyContext = EVP_PKEY_CTX_new(keyFromStore, NULL);
            if( !keyContext || EVP_PKEY_keygen_init(keyContext) <= 0 )
            {
                NSLog(@"Error obtainig key context");
                
                if( keyContext )
                {
                    EVP_PKEY_CTX_FREE(keyContext);
                    keyContext = NULL;
                }
            }
        }
         
        if( keyContext )
        {
            int bufferSize = CTIOSRSA_EVP_PKEY_CTX_get_friendly_name(keyContext, NULL, 0);
            NSMutableData *nameBuffer = [[NSMutableData alloc] initWithLength:bufferSize];

            int resultVal = CTIOSRSA_EVP_PKEY_CTX_get_friendly_name(keyContext, (void*)nameBuffer.bytes, nameBuffer.length);
            
            if( resultVal > 1 )
            {
                self.keyIdentifier = [NSString stringWithUTF8String:nameBuffer.bytes];
            }
            else //if( resultVal == -1 )
            {
                self.keyIdentifier = [Utils hexDataToString:keyIdData length:idLength isNeedSpacing:1];
            }
            
            [nameBuffer release];
            EVP_PKEY_CTX_FREE(keyContext);
        }
        
        EVP_PKEY_FREE(keyFromStore);
    }
}

- (void)viewDidUnload
{
    [self setStatusImage:nil];
    [self setHeaderTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    [statusImage release];
    [headerTable release];
    [cert release];

    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( self.store && (self.store.storeType == CST_MY) )
    {
        return 2;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cert header cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case 0:
        {
            cell.textLabel.text = @"Статус сертификата";
            
            UILabel *statusLabel = [[UILabel alloc] init];
            statusLabel.text = [self getCertStatusDescription];
            
            CGSize stringSize = [statusLabel.text sizeWithFont:statusLabel.font];
            statusLabel.frame = CGRectMake(0, 0, stringSize.width, stringSize.height);
            statusLabel.textColor = [UIColor blueColor];
            statusLabel.backgroundColor = [UIColor clearColor];
            
            cell.accessoryView = statusLabel;
            [statusLabel release];
        }
            break;
            
        case 1:
        {
            if( self.keyIdentifier )
            {
                cell.imageView.image = [UIImage imageNamed:@"key.png"];
                
                UILabel *statusLabel = [[UILabel alloc] init];
                statusLabel.text = self.keyIdentifier;
                
                CGSize stringSize = [statusLabel.text sizeWithFont:statusLabel.font];
                statusLabel.frame = CGRectMake(0, 0, stringSize.width, stringSize.height);
                statusLabel.textColor = [UIColor blueColor];
                statusLabel.backgroundColor = [UIColor clearColor];
                
                cell.accessoryView = statusLabel;
                [statusLabel release];
            }
            else
            {
                cell.textLabel.text = @"Отсутствует";
            }
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Сертификат";
            break;
            
        case 1:
            return @"Закрытый ключ";
            break;
            
        default:
            break;
    }
    
    return @"Error! Wrong section number.";
}

#pragma mark - Table view delegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 22;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if( 0 == section )
    {
        return 30;
    }
       
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - status functions

- (NSInteger)getCertStatus
{
    //TODO: Implement - return status value after verifying? or remove method and use method from CertificateInfo
    return 0;
}

- (NSString*)getCertStatusDescription
{
    NSInteger certStatus = [self getCertStatus];
    
    switch (certStatus) {
        case 0:
            return @"Действителен";
            break;
            
        default:
            break;
    }
    
    return @"Статус неизвестен";
}

@end
