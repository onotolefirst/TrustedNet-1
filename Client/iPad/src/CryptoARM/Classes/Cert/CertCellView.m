#import "CertCellView.h"

@implementation CertCellView

@synthesize certSubject, certIssuer, certValidTo, certImageView, checked, selectionImageView;

- (id)init
{
    self = [super init];
    if (self) {
        checked = NO;
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
    [certSubject release];
    [certIssuer release];
    [certValidTo release];
    [certImageView release];
    [selectionImageView release];
    
    [super dealloc];
}

@end
