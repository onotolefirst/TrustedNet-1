#import <UIKit/UIKit.h>
#import "../Crypto/Certificate.h"

@interface CertCellView : UITableViewCell {
    UILabel *certSubject;
    UILabel *certIssuer;
    UILabel *certValidTo;
    UIImageView *certImageView;
    UIImageView *imgTick;
    bool checked; // for multiple select certificates, should be changed only in user defined code
}

@property (nonatomic, retain) IBOutlet UILabel *certSubject;
@property (nonatomic, retain) IBOutlet UILabel *certIssuer;
@property (nonatomic, retain) IBOutlet UILabel *certValidTo;
@property (nonatomic, retain) IBOutlet UIImageView *certImageView;
@property (nonatomic, retain) IBOutlet UIImageView *imgTick;
@property (nonatomic, assign) bool checked;

@end
