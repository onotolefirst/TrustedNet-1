//
//  ParametersPanel.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParametersPanel.h"

#import "ProfileViewController.h"
#import "Crypto.h"

#import "SelectCertViewController.h"
#import "SelectOidViewController.h"
#import "PathHelper.h"
#import "SelectAlgorithm.h"

@implementation ParametersPanel
@synthesize title;
@synthesize editMode;
@synthesize parentProfile;
@synthesize signUsages;

- (id)initWithParentProfile:(Profile*)profileFromParent
{
    self = [super init];
    if (self) {
        self.parentProfile = profileFromParent;
        
        self.title = @"Parameters";
        switchEncryptToSender = nil;
        switchDetachedSign = nil;
        switchSignArchive = nil;
        switchSignResourceIsFile = nil;
        
        signUsages = nil;
        self.editMode = YES;
    }
    return self;
}

- (void)dealloc
{
    if( pinField )
    {
        [pinField release];
    }
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (enum EnmPageType)panelTypeId
{
    return panelTypeIdValue;
}

- (void)setPanelTypeId:(enum EnmPageType)panelTypeId
{
    panelTypeIdValue = panelTypeId;
}

- (void)refreshTableData
{
    [((UITableView*)self.view) reloadData];
}

- (void)refreshTableSections:(NSIndexSet*)sectionsToReload
{
    [((UITableView*)self.view) reloadSections:sectionsToReload withRowAnimation:UITableViewRowAnimationFade];
}

- (NSString*)getCommonNameFromDNString:(NSString*)dnString
{
    // split id into subject name, seria and issuer name
    NSArray *idStrings = [dnString componentsSeparatedByString:@""];
    if( !idStrings || !idStrings.count )
    {
        return dnString;
    }
    
    // remove siding quotes and split subject name into parts
    NSString *subjectName = [idStrings objectAtIndex:0];
    subjectName = [subjectName substringWithRange:NSMakeRange(1, subjectName.length-2)];
    idStrings = [subjectName componentsSeparatedByString:@","];
    if( !idStrings || !idStrings.count )
    {
        return dnString;
    }
    
    // search common name
    NSArray *elementComponentsArray;
    NSString *commonNameId = [NSString stringWithCString:SN_commonName encoding:NSASCIIStringEncoding];
    for (NSString *currentSubjectElement in idStrings) {
        // split name componnt into short name and value
        elementComponentsArray = [currentSubjectElement componentsSeparatedByString:@"="];
        if( !elementComponentsArray || (elementComponentsArray.count < 2) )
        {
            continue;
        }
        
        if( [commonNameId compare:[elementComponentsArray objectAtIndex:0]] != NSOrderedSame )
        {
            continue;
        }
           
        return [elementComponentsArray objectAtIndex:1];
    }
       
    return dnString;
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStyleGrouped] autorelease];
    ((UITableView*)self.view).dataSource = self;
    ((UITableView*)self.view).delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    if( switchEncryptToSender )
    {
        [switchEncryptToSender release];
    }
    if( switchDetachedSign )
    {
        [switchDetachedSign release];
    }
    if( switchSignArchive )
    {
        [switchSignArchive release];
    }
    if( switchSignResourceIsFile )
    {
        [switchSignResourceIsFile release];
    }
    if( switchRemoveFileAfterEncryption )
    {
        [switchRemoveFileAfterEncryption release];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshTableData];
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
    // Return the number of sections.
    switch (self.panelTypeId) {
        case PT_SIGNING:
            return 7;
            break;
            
        case PT_ENCRYPTION:
            return 6;
            break;
            
        case PT_DECRYPTION:
            return 1;
            break;
            
        case PT_CERTPOLICY:
            return 2;
            break;
            
        case PT_ADDITIONAL_SIGN_PARAMS:
            return 4;
            break;
            
        default:
            break;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    switch (self.panelTypeId) {
        case PT_SIGNING:
        {
            if( 3 == section )
            {
                NSInteger rowCount = 0;
                if( parentProfile.signType && parentProfile.signType.length )
                {
                    rowCount++;
                }
                
                if( parentProfile.signComment && parentProfile.signComment.length )
                {
                    rowCount++;
                }
                
                if( parentProfile.signResourceIsFile || (parentProfile.signResource && parentProfile.signResource.length) )
                {
                    rowCount++;
                }
                
                if( !rowCount )
                {
                    rowCount = 1;
                }
                
                return rowCount;
            }
            else if( 5 == section )
            {
                return 2;
            }
        }
            break;
            
        case PT_ENCRYPTION:
        {
            if( 4 == section )
            {
                return 2;
            }
            
            if( 3 == section && self.parentProfile.recieversCertificates && (self.parentProfile.recieversCertificates.count > 1) )
            {
                return self.parentProfile.recieversCertificates.count;
            }
            
            return 1;
        }
            break;
            
//        case PT_DECRYPTION:
        case PT_CERTPOLICY:
        {
            if( 0 == section && self.parentProfile.encryptCertFilter && (self.parentProfile.encryptCertFilter.count > 1) )
            {
                return self.parentProfile.encryptCertFilter.count;
            }
            else if( 1 == section && self.parentProfile.certsForCrlValidation && (self.parentProfile.certsForCrlValidation.count > 1) )
            {
                return self.parentProfile.certsForCrlValidation.count;
            }
        }
            break;
            
        case PT_ADDITIONAL_SIGN_PARAMS:
        {
            if( 0 == section )
            {
                if( !self.signUsages )
                {
                    NSString *usagesFileName = [[NSString stringWithFormat:@"%@/%@", [PathHelper getOperationalSettinsDirectoryPath], [PathHelper getSignUsagesFileName]] copy];
                    
                    NSURL *usagesUrl = [NSURL fileURLWithPath:usagesFileName];
                    NSError *fileCheckError = nil;
                    
                    CertUsageHelper *signUsagesHelper = [[CertUsageHelper alloc] init];
                    
                    if( [usagesUrl checkResourceIsReachableAndReturnError:&fileCheckError] )
                    {
                        [signUsagesHelper readUsages:usagesFileName];
                    }
                    else
                    {
                        [signUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.2.643.6.3.1.0" andDescription:NSLocalizedString(@"PROFILE_PARAMETERS_OID_CREATION", @"Создание")]];
                        [signUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.2.643.6.3.1.1" andDescription:NSLocalizedString(@"PROFILE_PARAMETERS_OID_CORRECTED", @"Исправлено")]];
                        [signUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.2.643.6.3.1.2" andDescription:NSLocalizedString(@"PROFILE_PARAMETERS_OID_ACQUAINT", @"Ознакомлен")]];
                        [signUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.2.643.6.3.1.3" andDescription:NSLocalizedString(@"PROFILE_PARAMETERS_OID_AGREED", @"Согласовано")]];
                        [signUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.2.643.6.3.1.4" andDescription:NSLocalizedString(@"PROFILE_PARAMETERS_OID_SIGNED", @"Подписано")]];
                        [signUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.2.643.6.3.1.5" andDescription:NSLocalizedString(@"PROFILE_PARAMETERS_OID_AFFIRM", @"Утверждено")]];
                        
                        [signUsagesHelper writeUsages:usagesFileName];
                    }
                    
                    [usagesFileName release];
                    
                    self.signUsages = signUsagesHelper.certUsages;
                    [signUsagesHelper release];
                }
                
                if( parentProfile.signType && parentProfile.signType.length )
                {
                    // check if usage is present in usages list
                    BOOL usageFound = NO;
                    for (CertUsage *currentUsage in self.signUsages)
                    {
                        if( [currentUsage.usageId compare:parentProfile.signType] == NSOrderedSame )
                        {
                            usageFound = YES;
                            break;
                        }
                    }
                    
                    if( !usageFound )
                    {
                        NSMutableArray *tempUsageArr = [[NSMutableArray alloc] initWithArray:self.signUsages];
                        [tempUsageArr addObject:[CertUsage createUsageWithId:parentProfile.signType andDescription:parentProfile.signType]];
                        [tempUsageArr release];
                    }
                }
                
                return (self.signUsages.count + 1);
            }
        }
            break;
            
        default:
            break;
    }
    
    return 1;
}

- (void)composeEditableCell:(UITableViewCell*)cell withField:(UITextField**)pField textValue:(NSString*)value placeholder:(NSString*)placeholderKey actionSelector:(SEL)fieldAction
{
    cell.textLabel.text = @" ";
    UITextField *field;
    field = *pField;
    if( !field )
    {
        field = [[UITextField alloc] initWithFrame:cell.textLabel.bounds];
        *pField = field;
        
        field.borderStyle = UITextBorderStyleNone;
        field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        field.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        field.placeholder = NSLocalizedString(placeholderKey, @"Various values");
    }
    else
    {
        [field removeFromSuperview];
    }
    
    field.text = (value ? [NSString stringWithString:value] : @"");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:fieldAction name:UITextFieldTextDidChangeNotification object:field];
    
    cell.textLabel.autoresizesSubviews = YES;
    cell.textLabel.userInteractionEnabled = YES;
    [cell.textLabel addSubview:field];
}

- (void)composeCell:(UITableViewCell*)cell withSwitch:(UISwitch**)cellSwitch value:(BOOL)switchValue description:(NSString*)cellDescription andAction:(SEL)switchAction;
{
    cell.textLabel.text = cellDescription;
    UISwitch *localSwitch = *cellSwitch;
    if( !localSwitch )
    {
        localSwitch = [[UISwitch alloc] init];
        *cellSwitch = localSwitch;
    }

    localSwitch.on = switchValue;
    [localSwitch addTarget:self action:switchAction forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = localSwitch;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.userInteractionEnabled = self.editMode;
    
    UIButton *roundButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    
    switch (self.panelTypeId) {
        case PT_SIGNING:
        {
            switch (indexPath.section) {
                case 0:
                {
                    if( self.parentProfile.signCertificate )
                    {
                        cell.textLabel.text = [Crypto getDNFromX509_NAME:self.parentProfile.signCertificate.subject withNid:NID_commonName];
                    }
                    else
                    {
                        cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_CERTIFICATE_OWNER", @"Владелец сертификата");
                        cell.textLabel.textColor = [UIColor grayColor];
                    }
                    
                    if( self.parentProfile.signCertificate && !self.parentProfile.signHashAlgorithm )
                    {
                        //TODO: define default value for variable certificate key types
                        self.parentProfile.signHashAlgorithm = @"1.3.14.3.2.26"; //SHA-2 by default
                    }
                    
                    [roundButton addTarget:self action:@selector(selectSignCertAction) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = roundButton;
                }   
                    break;
                    
                case 1:
                {
                    [self composeEditableCell:cell withField:&pinField textValue:parentProfile.signCertPIN placeholder:@"PROFILE_PARAMETERS_ENTER_PIN" actionSelector:@selector(editSignPin:)];
                    pinField.secureTextEntry = YES;
                }
                    break;
                    
                case 2:
                    {
                        if( self.parentProfile.signHashAlgorithm )
                        {
                            int nid = OBJ_txt2nid(self.parentProfile.signHashAlgorithm.UTF8String);
                            cell.textLabel.text = [NSString stringWithCString:OBJ_nid2ln(nid) encoding:NSUTF8StringEncoding];
                        }
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                        if( !self.parentProfile.signCertificate )
                        {
                            cell.textLabel.textColor = [UIColor grayColor];
                            cell.userInteractionEnabled = NO;
                        }
                    }
                    break;
                    
                case 3:
                {
                    if( 0 == indexPath.row )
                    {
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                    
                    NSInteger valueNumber = -1;
                    NSString *currentValue = nil;
                    if( parentProfile.signType && parentProfile.signType.length )
                    {
                        valueNumber++;
                        // extract description from file storage
                        CertUsageHelper *signUsageHelper = [[CertUsageHelper alloc] initWithDictionary:[NSString stringWithFormat:@"%@/%@", [PathHelper getOperationalSettinsDirectoryPath], [PathHelper getSignUsagesFileName]]];
                        CertUsage *foundSignUsage = [signUsageHelper checkUsageWithId:parentProfile.signType];
                        currentValue = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"PROFILE_PARAMETERS_SIGNATURE_TYPE", @"Тип подписи"), (foundSignUsage ? foundSignUsage.usageDescription : parentProfile.signType)];
                        
                        [signUsageHelper release];
                    }
                    
                    if( valueNumber == indexPath.row )
                    {
                        cell.textLabel.text = currentValue;
                        break;
                    }
                    
                    if( parentProfile.signComment && parentProfile.signComment.length )
                    {
                        valueNumber++;
                        currentValue = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"PROFILE_PARAMETERS_COMMENT", @"Комментарий"), parentProfile.signComment];
                    }
                    
                    if( valueNumber == indexPath.row )
                    {
                        cell.textLabel.text = currentValue;
                        break;
                    }
                    
                    if( parentProfile.signResourceIsFile )
                    {
                        valueNumber++;
                        currentValue = NSLocalizedString(@"PROFILE_PARAMETERS_RESOURCE_IS_FILENAME", @"Ресурс - имя файла");
                    }
                    else if( parentProfile.signResource && parentProfile.signResource.length )
                    {
                        valueNumber++;
                        currentValue = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"PROFILE_PARAMETERS_RESOURCE_IDENTIFIER", @"Идентификатор ресурса"), parentProfile.signResource];
                    }
                    
                    if( valueNumber == indexPath.row )
                    {
                        cell.textLabel.text = currentValue;
                        break;
                    }
                    
                    if( valueNumber == -1 )
                    {
                        cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_MOT_SELECTED", @"Не выбраны");
                        cell.textLabel.textColor = [UIColor colorWithWhite:0.75 alpha:1];
                    }
                }
                    break;
                    
                case 4:
                {
                    cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_CREATE_DETACHED_SIGNATURE", @"Создать отделенную подпись");
                    
                    if( !switchDetachedSign )
                    {
                        switchDetachedSign = [[UISwitch alloc] init];
                    }
                    switchDetachedSign.on = self.parentProfile.signDetach;
                    [switchDetachedSign addTarget:self action:@selector(switchDetachChangeAction) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = switchDetachedSign;
                }
                    break;
                    
                case 5:
                    if( 0 == indexPath.row )
                    {
                        cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_CREATE_IN_BASE64", @"Формировать файл в BASE64");
                        if(FT_BASE64 == self.parentProfile.signFormatType)
                        {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        else
                        {
                            cell.accessoryType = UITableViewCellAccessoryNone;
                        }
                    }
                    else if( 1 == indexPath.row )
                    {
                        cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_CREATE_IN_DER", @"Формировать файл в DER");
                        if(FT_DER == self.parentProfile.signFormatType)
                        {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        else
                        {
                            cell.accessoryType = UITableViewCellAccessoryNone;
                        }
                    }
                    break;
                    
                case 6:
                {
                    cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_ARCHIVE_AFTER_SIGINING", @"Архивировать после создания подписи");
                    
                    if( !switchSignArchive )
                    {
                        switchSignArchive = [[UISwitch alloc] init];
                    }
                    switchSignArchive.on = self.parentProfile.signArchiveFiles;
                    [switchSignArchive addTarget:self action:@selector(switchSignArchiveChangeAction) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = switchSignArchive;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case PT_ENCRYPTION:
        {
            switch (indexPath.section) {
                case 0:
                {
                    if( self.parentProfile.encryptCertificate )
                    {
                        cell.textLabel.text = [Crypto getDNFromX509_NAME:self.parentProfile.encryptCertificate.subject withNid:NID_commonName];
                    }
                    else
                    {
                        cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_CERTIFICATE_OWNER", @"Владелец сертификата");
                        cell.textLabel.textColor = [UIColor grayColor];
                    }
                    
                    [roundButton addTarget:self action:@selector(selectEncryptionCertAction) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = roundButton;
                }
                    break;
                    
                case 1:
                    if( self.parentProfile.encryptCertificate )
                    {
                        cell.textLabel.text = [Crypto convertAsnObjectToString:self.parentProfile.encryptCertificate.x509->cert_info->key->algor->algorithm noName:NO];
                    }
                    else
                    {
                        cell.textLabel.text = @"";
                    }
                    
                    break;
                    
                case 2:
                {
                    cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_ENCRYPT_TO_SENDER", @"Шифровать в адрес отправителя");
                    
                    if( !switchEncryptToSender )
                    {
                        switchEncryptToSender = [[UISwitch alloc] init];
                    }
                    switchEncryptToSender.on = self.parentProfile.encryptToSender;
                    [switchEncryptToSender addTarget:self action:@selector(switchChangeAction) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = switchEncryptToSender;
                }
                    break;
                    
                case 3:
                {
                    if( self.parentProfile.recieversCertificates && self.parentProfile.recieversCertificates.count )
                    {
                        CertificateInfo *currentRcvCert = [self.parentProfile.recieversCertificates objectAtIndex:indexPath.row];
                        cell.textLabel.text = [Crypto getDNFromX509_NAME:currentRcvCert.subject withNid:NID_commonName];
                    }
                    else
                    {
                        cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_CERTIFICATE_OWNER", @"Владелец сертификата");
                        cell.textLabel.textColor = [UIColor grayColor];
                    }
                    
                    if( 0 == indexPath.row )
                    {
                        [roundButton addTarget:self action:@selector(selectRecieversCertsAction) forControlEvents:UIControlEventTouchUpInside];
                        cell.accessoryView = roundButton;
                    }
                }
                    break;
                    
                case 4:
                    if( 0 == indexPath.row )
                    {
                        cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_CREATE_IN_BASE64", @"Формировать файл в BASE64");
                        if(FT_BASE64 == self.parentProfile.encryptFormatType)
                        {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        else
                        {
                            cell.accessoryType = UITableViewCellAccessoryNone;
                        }
                    }
                    else if( 1 == indexPath.row )
                    {
                        cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_CREATE_IN_DER", @"Формировать файл в DER");
                        if(FT_DER == self.parentProfile.encryptFormatType)
                        {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        else
                        {
                            cell.accessoryType = UITableViewCellAccessoryNone;
                        }
                    }
                    break;
                    
                case 5:
                {
                    NSString *cellLabel = NSLocalizedString(@"PROFILE_PARAMETERS_REMOVE_SOURCE_FILE_AFTER_ENCRYPTION", @"Удалить исходный файл после шифрования");
                    [self composeCell:cell withSwitch:&switchRemoveFileAfterEncryption value:self.parentProfile.removeFileAfterEncryption description:cellLabel andAction:@selector(switchRemoveFileAfterEncryptionAction)];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case PT_DECRYPTION:
            if( 0 == indexPath.section )
            {
                if( self.parentProfile.decryptCertificate )
                {
                    cell.textLabel.text = [Crypto getDNFromX509_NAME:self.parentProfile.decryptCertificate.subject withNid:NID_commonName];
                }
                else
                {
                    cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_CERTIFICATE_OWNER", @"Владелец сертификата");
                    cell.textLabel.textColor = [UIColor grayColor];
                }
                
                [roundButton addTarget:self action:@selector(selectDecryptionCertAction) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = roundButton;
            }
            break;
            
        case PT_CERTPOLICY:
            if( 0 == indexPath.section )
            {
                if( self.parentProfile.encryptCertFilter && self.parentProfile.encryptCertFilter.count )
                {
                    CertUsage *curUsage = [self.parentProfile.encryptCertFilter objectAtIndex:indexPath.row];
                    cell.textLabel.text = ((curUsage.usageDescription && curUsage.usageDescription.length) ? curUsage.usageDescription : curUsage.usageId);
                }
                else
                {
                    cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_CERTIFICATE_USAGE", @"Назначение сертификата");
                    cell.textLabel.textColor = [UIColor grayColor];
                }
                
                if( 0 == indexPath.row )
                {
                    [roundButton addTarget:self action:@selector(selectEncCertsFilter) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = roundButton;
                }
            }
            else if( 1 == indexPath.section )
            {
                if( self.parentProfile.certsForCrlValidation && self.parentProfile.certsForCrlValidation.count )
                {
                    cell.textLabel.text = [self getCommonNameFromDNString:(NSString*)[self.parentProfile.certsForCrlValidation objectAtIndex:indexPath.row]];
                }
                else
                {
                    cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_CERTIFICATE_OWNER", @"Владелец сертификата");
                    cell.textLabel.textColor = [UIColor grayColor];
                }
                
                if( 0 == indexPath.row )
                {
                    [roundButton addTarget:self action:@selector(selectCertsForValidationAction) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = roundButton;
                }
            }
            break;
            
        case PT_ADDITIONAL_SIGN_PARAMS:
        {
            switch (indexPath.section) {
                case 0:
                {
                    if( 0 == indexPath.row )
                    {
                        cell.textLabel.text = NSLocalizedString(@"PROFILE_PARAMETERS_NOT_SPECIFIED", @"Не задано");
                        if( !parentProfile.signType || !parentProfile.signType.length )
                        {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                    }
                    
                    CertUsage *rowUsage = [self.signUsages objectAtIndex:(indexPath.row-1)];
                    cell.textLabel.text = rowUsage.usageDescription;
                    if( [rowUsage.usageId compare:parentProfile.signType] == NSOrderedSame )
                    {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                }
                    break;
                    
                case 1:
                {
                    [self composeEditableCell:cell withField:&commentField textValue:parentProfile.signComment placeholder:@"PROFILE_PARAMETERS_ABSENT" actionSelector:@selector(editSignComment:)];
                }
                    break;
                    
                case 2:
                {
                    NSString *fieldText = (parentProfile.signResourceIsFile ? resourceField.text : parentProfile.signResource);
                    [self composeEditableCell:cell withField:&resourceField textValue:fieldText placeholder:@"PROFILE_PARAMETERS_ABSENT" actionSelector:@selector(editSignResource:)];
                    
                    resourceField.userInteractionEnabled = !parentProfile.signResourceIsFile;
                    if( parentProfile.signResourceIsFile )
                    {
                        resourceField.textColor = [UIColor colorWithWhite:0.75 alpha:1];
                    }
                    else
                    {
                        resourceField.textColor = [UIColor blackColor];
                    }
                }
                    break;
                    
                case 3:
                {
                    [self composeCell:cell withSwitch:&switchSignResourceIsFile value:parentProfile.signResourceIsFile description:NSLocalizedString(@"PROFILE_PARAMETERS_INCLUDE_FILE_NAME_INTO_RESOURECE_ID", @"Включить имя файла в идентификатор ресурса") andAction:@selector(switchSignResourceisFileAction)];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    if( PT_SIGNING == self.panelTypeId )
    {
        switch (indexPath.section) {
            case 2:
            {
                SelectAlgorithm *selAlgPage = [[SelectAlgorithm alloc] initWithParentProfile:self.parentProfile andPageType:APT_SIGN_HASH];
                [parentNavController pushNavController:selAlgPage];
                [selAlgPage release];
            }
                break;
                
            case 3:
            {
                ParametersPanel *additionalSettingsPanel = [[ParametersPanel alloc] initWithParentProfile:self.parentProfile];
                
                additionalSettingsPanel.panelTypeId = PT_ADDITIONAL_SIGN_PARAMS;
                additionalSettingsPanel.title = NSLocalizedString(@"PROFILE_PARAMETERS_ADDITIONAL_SIGN_PARAMETERS", @"Дополнительные параметры подписи");
                additionalSettingsPanel.editMode = self.editMode;
                [additionalSettingsPanel setParentNavigationController:parentNavController];
                
                [parentNavController pushNavController:additionalSettingsPanel];
                [additionalSettingsPanel release];
            }
                break;
                
            case 5:
            {
                self.parentProfile.signFormatType = (0 == indexPath.row) ? FT_BASE64 : FT_DER;
                
                // Redraw section with new value
                [((UITableView*)self.view) reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            }
                break;
                
            default:
                break;
        }
    }
    
    if( (PT_ENCRYPTION == self.panelTypeId) && (4 == indexPath.section) )
    {
        self.parentProfile.encryptFormatType = (0 == indexPath.row) ? FT_BASE64 : FT_DER;

        // Redraw section with new value
        [((UITableView*)self.view) reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if( (PT_ADDITIONAL_SIGN_PARAMS == self.panelTypeId) && (indexPath.section == 0) )
    {
        if( indexPath.row == 0 )
        {
            parentProfile.signType = nil;
        }
        else
        {
            CertUsage *rowUsage = [self.signUsages objectAtIndex:indexPath.row-1];
            parentProfile.signType = rowUsage.usageId;
        }
        
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [((UITableView*)self.view) deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (self.panelTypeId) {
        case PT_SIGNING:
        {
            switch (section) {
                case 0:
                    return NSLocalizedString(@"PROFILE_PARAMETERS_SIGNATURE_CERTIFICATES", @"Сертификаты подписи");
                    break;
                    
                case 1:
                    return NSLocalizedString(@"PROFILE_PARAMETERS_KEY_PIN_CODE", @"Код доступа к ключу (PIN-код)");
                    break;
                    
                case 2:
                    return NSLocalizedString(@"PROFILE_PARAMETERS_HASH_ALG_TYPE", @"Тип хеш-алгоритма");
                    break;
                    
                case 3:
                    return NSLocalizedString(@"PROFILE_PARAMETERS_ADDITIONAL_SIGN_PARAMETERS", @"Дополнительные параметры подписи");
                    break;
                    
                case 4:
                    return NSLocalizedString(@"PROFILE_PARAMETERS_SIGNATURE_SAVING", @"Сохранение подписи");
                    break;
                    
                case 5:
                    return NSLocalizedString(@"PROFILE_PARAMETERS_RESULT_FILE_FORMAT", @"Формат выходного файла");
                    break;
                    
                case 6:
                    return @"";
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case PT_ENCRYPTION:
        {
            switch (section) {
                case 0:
                    return NSLocalizedString(@"PROFILE_PARAMETERS_ENCRYPTION_CERT", @"Сертификат шифрования");
                    break;
                    
                case 1:
                    return NSLocalizedString(@"PROFILE_PARAMETERS_ENCRYPT_ALG_TYPE", @"Тип алгоритма шифрования");
                    break;
                    
                case 2:
                case 5:
                    return @"";
                    break;
                    
                case 3:
                    return NSLocalizedString(@"PROFILE_PARAMETERS_RECIEVERS_CERTIFICATES", @"Сертификаты получатетей");
                    break;
                    
                case 4:
                    return NSLocalizedString(@"PROFILE_PARAMETERS_RESULT_FILE_FORMAT", @"Формат выходного файла");
                    break;
                    
                case 6:
                    return NSLocalizedString(@"PROFILE_PARAMETERS_SECURE_DELETION", @"Гарантированное удаление");
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case PT_DECRYPTION:
            if( 0 == section )
            {
                return NSLocalizedString(@"PROFILE_PARAMETERS_ENCRYPTING_CERTIFICATE", @"Сертификат расшифрования");
            }
            break;
            
        case PT_CERTPOLICY:
            if( 0 == section )
            {
                return NSLocalizedString(@"PROFILE_PARAMETERS_ENCRYPT_CERTIFICATES_FILTER", @"Фильтр назначений сертификатов шифрования");
            }
            else if( 1 == section )
            {
                return NSLocalizedString(@"PROFILE_PARAMETERS_CERTIFICATES_FOR_VALIDATION_BY_ONLINE_CRL", @"Сертификаты для которых требуется загрузка CRL из УЦ");
            }
            break;
            
        case PT_ADDITIONAL_SIGN_PARAMS:
        {
            switch (section) {
                case 0:
                    return NSLocalizedString(@"PROFILE_PARAMETERS_SIGN_USAGE_COMMENT", @"Комментарий по использованию подписи");
                    break;
                    
                case 1:
                    return NSLocalizedString(@"PROFILE_PARAMETERS_SIGN_COMMENT", @"Комментарий подписи");
                    break;
                    
                case 2:
                    return NSLocalizedString(@"PROFILE_PARAMETERS_RESOURCE_IDENTIFIER", @"Идентификатор ресурса");
                    break;
                    
                case 3:
                    return @"";
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"Warning: Wrong section index for:\n\tpanel type\t%u\n\tsection\t%u", self.panelTypeId, section];
}

#pragma mark - NavigationSource protocol supporting

+ (NSString*)itemTag
{
    return @"ParametersPanel";
}

- (NSString*)itemTag
{
    return [ParametersPanel itemTag];
}

//- (NSString*)title
//{
//    return @"Parameters";
//}

- (NSArray*)getAdditionalButtons
{
    return nil;
}

- (BOOL)preserveController
{
    return FALSE;
}

- (SettingsMenuSource*)settingsMenu
{
    return nil;
}

- (Class)getSavingObjcetClass
{
    return [ProfileViewController class];
}

- (id<MenuDataRefreshinProtocol>)createSavingObject
{
    return nil;
}

//- (void)dismissPopovers
//{
//    
//}

#pragma mark - Navigation Controller Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//TODO: renewing problem. Crash error with navigation controller delegate
//  see method prepareItem of DetailNavController class
    
//    if( ((ProfileViewController*)parentPageRef).editMode )
//    {
//        [self refreshTableData];
//    }
}

#pragma mark - Controls actions

- (void)switchChangeAction
{
    self.parentProfile.encryptToSender = switchEncryptToSender.on;
    
    if( self.parentProfile.encryptCertificate )
    {
        CertificateInfo *foundCert = nil;
        for (CertificateInfo *currentCert in self.parentProfile.recieversCertificates) {
            if( !X509_issuer_and_serial_cmp(currentCert.x509, self.parentProfile.encryptCertificate.x509) )
            {
                foundCert = currentCert;
                break;
            }
        }
        
        if( switchEncryptToSender.on )
        {
            if( !foundCert )
            {
                //add certificate to recievers if not present in list
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.parentProfile.recieversCertificates];
                [tempArray addObject:self.parentProfile.encryptCertificate];
                self.parentProfile.recieversCertificates = tempArray;
            }
        }
        else
        {
            if( foundCert )
            {
                //remove cert from recievers if present in list
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.parentProfile.recieversCertificates];
                [tempArray removeObject:foundCert];
                self.parentProfile.recieversCertificates = tempArray;
            }
        }
        
        [self refreshTableSections:[NSIndexSet indexSetWithIndex:3]];
    }
}

- (void)switchDetachChangeAction
{
    self.parentProfile.signDetach = switchDetachedSign.on;
}

- (void)switchSignArchiveChangeAction
{
    self.parentProfile.signArchiveFiles = switchSignArchive.on;
}

- (void)switchSignResourceisFileAction
{
    self.parentProfile.signResourceIsFile = switchSignResourceIsFile.on;
    self.parentProfile.signResource = parentProfile.signResourceIsFile ? @"" : resourceField.text;
    [((UITableView*)self.view) reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)switchRemoveFileAfterEncryptionAction
{
    self.parentProfile.removeFileAfterEncryption = switchRemoveFileAfterEncryption.on;
}

- (void)selectSignCertAction
{
    SelectCertViewController *newPanel = [[SelectCertViewController alloc] initWithProfile:self.parentProfile andSelectType:SCPT_SIGN_CERT];
    [parentNavController pushNavController:newPanel];
    
    [newPanel release];
}

- (void)selectEncryptionCertAction
{
    SelectCertViewController *newPanel = [[SelectCertViewController alloc] initWithProfile:self.parentProfile andSelectType:SCPT_ENCRYPT_CERT];
    [parentNavController pushNavController:newPanel];
    
    [newPanel release];
}

- (void)selectRecieversCertsAction
{
    SelectCertViewController *newPage = [[SelectCertViewController alloc] initWithProfile:self.parentProfile andSelectType:SCPT_RECIEVERS_CERTS];
    [parentNavController pushNavController:newPage];
    
    [newPage release];
}

- (void)selectDecryptionCertAction
{
    SelectCertViewController *newPage = [[SelectCertViewController alloc] initWithProfile:self.parentProfile andSelectType:SCPT_DECRYPT_CERT];
    [parentNavController pushNavController:newPage];
    
    [newPage release];
}

- (void)selectCertsForValidationAction
{
    SelectCertViewController *newPage = [[SelectCertViewController alloc] initWithProfile:self.parentProfile andSelectType:SCPT_VALIDATION_CERTS];
    [parentNavController pushNavController:newPage];
    
    [newPage release];
}

- (void)selectEncCertsFilter
{
    SelectOidViewController *newPage = [[SelectOidViewController alloc] initWithProfile:self.parentProfile];
    [parentNavController pushNavController:newPage];
    [newPage release];
}

- (void)editSignPin:(id)sender
{
    self.parentProfile.signCertPIN = pinField.text;
}

- (void)editSignComment:(id)sender
{
    self.parentProfile.signComment = commentField.text;
}

- (void)editSignResource:(id)sender
{
    self.parentProfile.signResource = parentProfile.signResourceIsFile ? @"" : resourceField.text;
}

@end
