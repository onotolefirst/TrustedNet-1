#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>
#import "../Crypto/Certificate.h"
#import "../Crypto/Crypto.h"

#import "DetailNavController.h"

@interface CertDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NavigationSource,UITextFieldDelegate> {
    UIColor *textColor;
    CertificateInfo *certInfo;
    NSArray *arrayOU;
    int autoresizingMask;
    
    SettingsMenuSource *settingsMenu;
    
    UIPopoverController *chainPopover;
    UIBarButtonItem *chainButton;
    
    DetailNavController *parentController;
}

- (id) initWithCertInfo:(CertificateInfo*) cert;

- (void)constructSettingsMenu;

@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) CertificateInfo *certInfo;
@property (nonatomic, retain) NSArray *arrayOU;
@property (nonatomic, assign) int autoresizingMask;

- (void)dismissPopovers;

- (void)chainButtonAction:(id)sender;

@end
