#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "../Crypto/Crypto.h"
#import "../Utils/Utils.h"
#import "../Crypto/Certificate.h"
#import <QuickLook/QuickLook.h>
#import "QuickLook/QLPreviewController.h"
#import "DetailNavController.h"
#import "RecipientCellView.h"
#import "../Detail/SystemSettingsMenuViewController.h"
#import "AddressBook/AddressBook.h"
#import "AdvancedAddressBookViewController.h"

#include "time.h"
#include <Openssl/bio.h>
#include <Openssl/sha.h>
#include <Openssl/x509.h>
#include <Openssl/safestack.h>
#include <Openssl/asn1.h>
#include <Openssl/ctiosrsa.h>
#include <Openssl/store.h>

typedef enum
{
    ENCIPHER_OPERATION = 0,
    DECIPHER_OPERATION,
    OPEN_IN_OPERATION
} EnumOperationType;

@interface WizardEncryptViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate,NavigationSource,UIDocumentInteractionControllerDelegate,MFMailComposeViewControllerDelegate,UITextFieldDelegate> {
    STACK_OF(X509) *certArray;
    UIImageView *imageDoc; // simple image of the opened document; is filled based on the document extention
    UIImageView *imageProfile;
    UILabel *documentName; // contains only name
    UILabel *creationDate; // document creation date
    UILabel *documentSize; // file size
    NSString *inputFilePath;      // plain text file before encrypting
    NSString *encryptedFilePath;  // encrypted file(after encryption)
    NSString *resultTempFilePath;
    SettingsMenuSource *settingsMenu;
    DetailNavController *parentController;
    NSURL *urlToRecievedFile;
    UINavigationBar *navDocRecipList;
    UITableView *tblRecipients;
    UIDocumentInteractionController *docInteractionController;
    EnumOperationType operationType;
    EVP_PKEY *private_key;
    UIButton *btnSelectSettings;
    UIPopoverController *settingsMenuPopover;
    UIBarButtonItem *btnAddRecipients;
    bool isShowingLandscapeView;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageDoc;
@property (nonatomic, retain) IBOutlet UIImageView *imageProfile;
@property (nonatomic, retain) IBOutlet UILabel *documentName;
@property (nonatomic, retain) IBOutlet UILabel *creationDate;
@property (nonatomic, retain) IBOutlet UILabel *documentSize;
@property (nonatomic, retain) IBOutlet UINavigationBar *navDocRecipList;
@property (nonatomic, retain) IBOutlet UITableView *tblRecipients;
@property (nonatomic, retain) IBOutlet UIButton *btnSelectSettings;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnAddRecipients;
@property (nonatomic, retain) UIDocumentInteractionController *docInteractionController;
@property (nonatomic, retain) UIPopoverController *settingsMenuPopover;
@property (nonatomic, retain) NSURL *urlToRecievedFile;
@property (nonatomic, assign) EnumOperationType operationType;
@property (nonatomic, assign) EVP_PKEY *private_key;
@property (nonatomic, assign) bool isShowingLandscapeView;

- (void)setupDocumentControllerWithURL:(NSURL *)url;
- (id)initWithNibName:(NSString *)nibNameOrNil withFileURL:(NSURL*)url bundle:(NSBundle *)nibBundleOrNil;
- (void)constructSettingsMenu;

// crypto operations
- (void)encipherAndSendEmail;
- (void)encipherAndOpenIn;
- (void)decipherAndOpenIn;
- (void)decipherAndSendEmail;
- (void)reencipherAndOpenIn;
- (void)reencipherAndSendEmail;
- (void)actionSendEmail;
- (void)actionOpenIn;
- (void)showWarningUnableDecipher;
- (void)showSettingsMenu;

@end
