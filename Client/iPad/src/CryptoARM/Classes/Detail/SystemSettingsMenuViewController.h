#import <UIKit/UIKit.h>

#import "SystemSettingsMenuCell.h"
#import "SystemSettingsMenuCellContent.h"

@interface SystemSettingsMenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *menuItemsArray;

    UITableView *menuTable;
    UIPopoverController *settingsMenuPopover;
}

@property(nonatomic, retain) UITableView *menuTable;
@property(nonatomic, retain) NSMutableArray *menuItemsArray;
@property(nonatomic, retain) UIPopoverController *settingsMenuPopover;

//- (void)applyMenuSource:(SystemSettingsMenu*)source;
- (CGFloat)calculateMenuHeight;
- (void)addMenuItem:(NSString*)itemTitle andCreationDate:(NSString *)strCreationDate andOwner:(NSString *)strOwner;
- (void)setPopoverController:(UIPopoverController *)controller;

@end
