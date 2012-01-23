//
//  CertUsageViewController.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CertUsageViewController.h"

#import "CertificateUsageMenuModel.h"


@implementation CertUsageViewController

@synthesize usage;
@synthesize usageImage;
@synthesize idLabel;
@synthesize descriptionLabel;
@synthesize idField;
@synthesize descriptionField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUsage:(CertUsage*)certUsage idLabel:(NSString*)labelId descriptionLabel:(NSString*) labelDescr
{
    self = [super init];
    if(self)
    {
        self.usage = [[certUsage copy] autorelease];
        
        titleForId = ( labelId ? labelId : @"Объектный идентификатор" );
        titleForDescription = ( labelDescr ? labelDescr : @"Назначение сертификата" );
        
        parentNavController = nil;
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
    
    self.idField.text = self.usage.usageId;
    self.descriptionField.text = self.usage.usageDescription;
    
    self.idLabel.text = titleForId;
    self.descriptionLabel.text = titleForDescription;
    
    buttonsBar = [[SaveDelButtonsPanelController alloc] initWithSaveAction:@selector(buttonSave:) andDelAction:@selector(buttonDelete:) forObject:self];
    [self.view addSubview:buttonsBar.view];
    [buttonsBar setKeyboardResponders:[NSArray arrayWithObjects:idField, descriptionField, nil]];
    
    buttonsBar.keyboardPositionDelegate = self;
}

- (void)viewDidUnload
{
    [self setUsageImage:nil];
    [self setIdLabel:nil];
    [self setDescriptionLabel:nil];
    [self setIdField:nil];
    [self setDescriptionField:nil];
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
    [buttonsBar release];
    if( usage )
    {
        [usage release];
    }
    
    [usageImage release];
    [idLabel release];
    [descriptionLabel release];
    [idField release];
    [descriptionField release];
    [super dealloc];
}

#pragma mark - NavigationSource protocol supporting

+ (NSString*)itemTag
{
    return @"CertUsageViewController";
}

- (NSString*)itemTag
{
    return [CertUsageViewController itemTag];
}

- (NSString*)title
{
    return NSLocalizedString(@"CERTIFICATE_USAGE_TITLE", @"Certificate usage title");
}

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

#pragma mark - Controls actions

- (BOOL)buttonDelete:(id)sender
{
    if( !usage.usageId || ![usage.usageId length] )
    {
        NSLog(@"Wraning! Element not added into dictionary.");
        return FALSE;
    }
    
    CertificateUsageMenuModel *usageSaver = (CertificateUsageMenuModel *)[self getSavingObject];
    
    if( !usageSaver )
    {
        NSLog(@"Error deleting data: can't obtain saving oject.");
        return FALSE;
    }
    
    [usageSaver removeElement:usage];
    [parentNavController refreshMenuData];
    
    [parentNavController.navCtrlr popViewControllerAnimated:YES];
    return TRUE;
}

- (BOOL)buttonSave:(id)sender
{
    NSRange foundRange = [self.idField.text rangeOfString:@"^([1-9]{1}\\d*\\.)+[1-9]{1}\\d*$" options:NSRegularExpressionSearch];
    if( foundRange.location != 0 || foundRange.length != self.idField.text.length )
    {
        NSLog(@"Warning: wrong input. Entered ID is not OID (by RFC 3061):\n\t%@", self.idField.text);
        
        //TODO: localize warning message
        NSString *idFieldName = @"Объектный идентификатор";
        NSString *warningMessage = [NSString stringWithFormat:@"Строка, введенная в поле \"%@\" не является OID-ом:\n\n%@", idFieldName, self.idField.text];
        NSString *warningTitle = @"Предупреждение";
        
        UIAlertView *alertDialog = [[UIAlertView alloc] initWithTitle:warningTitle message:warningMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertDialog show];
        
        [alertDialog release];
        return FALSE;
    }
                          
                          
    CertificateUsageMenuModel *usageSaver = (CertificateUsageMenuModel *)[self getSavingObject];
    
    if( !usageSaver )
    {
        NSLog(@"Error saving data: can't obtain saving oject.");
        return FALSE;
    }

    if( (!usage.usageId || ![usage.usageId length]) ||  ([usage.usageId compare:self.idField.text] != NSOrderedSame) )
    {
        CertUsage *newUsage = [[CertUsage alloc] initWithId:self.idField.text andDescription:self.descriptionField.text];
        if( [usageSaver checkIfExisting:newUsage] )
        {
            NSLog(@"Warning! usage already exists. Aborting saving.");
            
            //TODO: localize warning message
            NSString *warningTitle = @"Предупреждение";
            NSString *warningMessage = @"Данный объектный идентификатор уже присутствует в справочнике. Введите новый идентификатор или измените существующий.";
            
            UIAlertView *alertDialog = [[UIAlertView alloc] initWithTitle:warningTitle message:warningMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertDialog show];

            [alertDialog release];
            [newUsage release];
            return FALSE;
        }
        [newUsage release];
    }
    
    
    [usageSaver removeElement:usage];
    
    usage.usageId = self.idField.text;
    usage.usageDescription = self.descriptionField.text;

    [usageSaver addElement:usage];
    [parentNavController refreshMenuData];
    
    return TRUE;
}

- (Class)getSavingObjcetClass
{
    return [CertificateUsageMenuModel class];
}

- (id<MenuDataRefreshinProtocol>*)createSavingObject
{
    return (id<MenuDataRefreshinProtocol>*)[[[CertificateUsageMenuModel alloc] init] autorelease];
}
     
@end
