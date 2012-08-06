#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>
#import "../Crypto/Certificate.h"
#import "../Crypto/Crypto.h"

#import "CertChainViewController.h"

#import "CommonDetailController.h"
#import "CertDetailHeaderViewController.h"
#import "CheckStatusDialogViewControllerDelegate.h"

@interface CertDetailViewController : CommonDetailController <UITableViewDataSource, UITableViewDelegate, NavigationSource, UITextFieldDelegate, CertChainViewDelegate, UIAlertViewDelegate, CheckStatusDialogViewControllerDelegate, NSURLConnectionDataDelegate>
{
    UIColor *textColor;
    CertificateInfo *certInfo;
    NSArray *arrayOU;
    int autoresizingMask;
    
    SettingsMenuSource *settingsMenu;
    
    UIBarButtonItem *chainButton;
}

- (id) initWithCertInfo:(CertificateInfo*) cert;

- (void)constructSettingsMenu;

@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) CertificateInfo *certInfo;
@property (nonatomic, retain) NSArray *arrayOU;
@property (nonatomic, assign) int autoresizingMask;

@property (nonatomic, retain) CertDetailHeaderViewController *tableHeader;
@property (nonatomic, retain) CertificateStore *parentStore;

@property (nonatomic, retain) UIPopoverController *chainPopover;

// CRL loading properties
@property (nonatomic, retain) NSURLConnection *crlLoadingConnection;
@property (nonatomic, retain) NSMutableArray *cdpList;
@property (nonatomic, retain) UIView *activityView;
@property (nonatomic, retain) NSMutableData *crlData;

- (void)dismissPopovers;

- (void)chainButtonAction:(id)sender;

- (void)actionForCheckStatus;
- (void)actionForExportingCert;
- (void)actionForSendByEMail;
- (void)actionForPrintCertificate;
- (void)actionForRemoveCertificate;

- (void)startNextCrlLoadingFromCdpList;

@end
