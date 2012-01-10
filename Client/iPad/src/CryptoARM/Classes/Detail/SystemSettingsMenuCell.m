#import "SystemSettingsMenuCell.h"

@implementation SystemSettingsMenuCell

@synthesize title, creationDate, owner, imgSettings;

- (id)initWithTitle:(NSString*)itemTitle andCreationDate:(NSString *)strCreationDate andOwner:(NSString *)strOwner
{
    self = [super init];
    if ( self )
    {
        [title setText:itemTitle];
        [creationDate setText:strCreationDate];
        [owner setText:strOwner];

        // set image
        imgSettings.image = [UIImage imageNamed:@"profile.png"];
    }

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)dealloc
{
    [title release];
    [creationDate release];
    [owner release];
    [imgSettings release];
}

@end
