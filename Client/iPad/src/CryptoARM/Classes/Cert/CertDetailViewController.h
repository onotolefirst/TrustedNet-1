#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>
#import "../Crypto/Certificate.h"
#import "../Crypto/Crypto.h"

#import "DetailNavController.h"
#import "CertChainViewController.h"

#import "CertDetailHeaderViewController.h"

@interface CertDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NavigationSource,UITextFieldDelegate,CertChainViewDelegate> {
    UIColor *textColor;
    CertificateInfo *certInfo;
    NSArray *arrayOU;
    int autoresizingMask;
    
    SettingsMenuSource *settingsMenu;
    
    UIBarButtonItem *chainButton;
    
    DetailNavController *parentController;
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

- (void)dismissPopovers;

- (void)chainButtonAction:(id)sender;

@end
