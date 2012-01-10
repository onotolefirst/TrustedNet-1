#import <Foundation/Foundation.h>

@interface SystemSettingsMenuCell : UITableViewCell
{
    UILabel *title;
    UILabel *creationDate;
    UILabel *owner;
    UIImageView *imgSettings;
}

@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *creationDate;
@property (nonatomic, retain) IBOutlet UILabel *owner;
@property (nonatomic, retain) IBOutlet UIImageView *imgSettings;

- (id)initWithTitle:(NSString*)itemTitle andCreationDate:(NSString *)strCreationDate andOwner:(NSString *)strOwner;

@end
