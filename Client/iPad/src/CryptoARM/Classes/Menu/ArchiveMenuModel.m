 //
//  ArchiveMenuModel.m
//  CryptoARM
//
//  Created by Денис Бурдин on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArchiveMenuModel.h"
#import "MenuListController.h"

@implementation ArchiveMenuModel
@synthesize archive, tableContent, strFilename, currentTableView, isSubmenu, bZipped, parentNavigationController, navigationDelegate, dicEntireTreeView, root, selectedItems;

- (id)initWithFilePath:(NSString *)strPath isArchive:(BOOL)bArchive isRoot:(BOOL)bRoot parentNavController:(UINavigationController *)navController
{
    self = [super init];
    tableContent = [[NSMutableArray alloc] init];
    
    archive = [[ZipArchive alloc] init];
    strFilename = [[NSString alloc] initWithString:strPath];

    isSubmenu = false;
    bZipped = bArchive;
    root = bRoot;
    parentNavigationController = navController;
    
    NSArray *arrExtensions = [[strPath lastPathComponent] componentsSeparatedByString:@"."];

    // create custom view and content it
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    [viewHeader setBackgroundColor:[UIColor lightGrayColor]];

    if (!bArchive)
    {
        // set UIImageView with encipher picture
        UIButton *btnEncipher = [[UIButton alloc] initWithFrame:CGRectMake(8, 0, 34, 40)];
        [btnEncipher addTarget:self action:@selector(actionEnciper) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imgSign = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,34,40)];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"sign" ofType:@"png"];
        NSData *encipherImageData = [NSData dataWithContentsOfFile:filePath];
        [imgSign setImage:[UIImage imageWithData:encipherImageData]];
        [btnEncipher addSubview:imgSign];
        [viewHeader addSubview:btnEncipher];
    
        // set UIImageView with encrypt picture
        UIButton *btnEncrypt = [[UIButton alloc] initWithFrame:CGRectMake(48, 3, 51, 37)];
        [btnEncrypt addTarget:self action:@selector(actionEncrypt) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imgEncrypt = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,51,37)];
        filePath = [[NSBundle mainBundle] pathForResource:@"encrypt" ofType:@"png"];
        NSData *encryptImageData = [NSData dataWithContentsOfFile:filePath];
        [imgEncrypt setImage:[UIImage imageWithData:encryptImageData]];
        [btnEncrypt addSubview:imgEncrypt];
        [viewHeader addSubview:btnEncrypt];
    
        // set UIImageView with zip picture
        UIButton *btnZip = [[UIButton alloc] initWithFrame:CGRectMake(105, 5, 56, 35)];
        [btnZip addTarget:self action:@selector(actionZip) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imgZip = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,56,35)];
        filePath = [[NSBundle mainBundle] pathForResource:@"zip" ofType:@"png"];
        NSData *zipImageData = [NSData dataWithContentsOfFile:filePath];
        [imgZip setImage:[UIImage imageWithData:zipImageData]];
        [btnZip addSubview:imgZip];
        [viewHeader addSubview:btnZip];
    
        // set UIImageView with Open In picture
        UIButton *btnOpenIn = [[UIButton alloc] initWithFrame:CGRectMake(168, 2, 37, 38)];
        [btnOpenIn addTarget:self action:@selector(actionOpenIn) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imgOpenIn = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,37,38)];
        filePath = [[NSBundle mainBundle] pathForResource:@"send" ofType:@"png"];
        NSData *openInImageData = [NSData dataWithContentsOfFile:filePath];
        [imgOpenIn setImage:[UIImage imageWithData:openInImageData]];
        [btnOpenIn addSubview:imgOpenIn];
        [viewHeader addSubview:btnOpenIn];
    
        // set UIImageView with rename picture
        UIButton *btnRename = [[UIButton alloc] initWithFrame:CGRectMake(211, 2, 62, 38)];
        [btnRename addTarget:self action:@selector(actionRename) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imgRename = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,62,38)];
        filePath = [[NSBundle mainBundle] pathForResource:@"renameGray" ofType:@"png"];
        NSData *renameImageData = [NSData dataWithContentsOfFile:filePath];
        [imgRename setImage:[UIImage imageWithData:renameImageData]];
        [btnRename addSubview:imgRename];
        [viewHeader addSubview:btnRename];
    
        // set UIImageView with remove picture
        UIButton *btnRemove = [[UIButton alloc] initWithFrame:CGRectMake(279, 2, 31, 38)];
        [btnRemove addTarget:self action:@selector(actionRemove) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imgRemove = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,31,38)];
        filePath = [[NSBundle mainBundle] pathForResource:@"remove" ofType:@"png"];
        NSData *removeImageData = [NSData dataWithContentsOfFile:filePath];
        [imgRemove setImage:[UIImage imageWithData:removeImageData]];
        [btnRemove addSubview:imgRemove];
        [viewHeader addSubview:btnRemove];
    }
    else
    {
        // set UIImageView with extract picture
        UIButton *btnExtract = [[UIButton alloc] initWithFrame:CGRectMake(90, 2, 34, 40)];
        [btnExtract addTarget:self action:@selector(actionExtract) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imgExtract = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,34,38)];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"extract" ofType:@"png"];
        NSData *extractImageData = [NSData dataWithContentsOfFile:filePath];
        [imgExtract setImage:[UIImage imageWithData:extractImageData]];
        [btnExtract addSubview:imgExtract];
        [viewHeader addSubview:btnExtract];

        // set UIImageView with add picture
        UIButton *btnAdd = [[UIButton alloc] initWithFrame:CGRectMake(200, 2, 34, 40)];
        [btnAdd addTarget:self action:@selector(actionAdd) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imgAdd = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,38,38)];
        filePath = [[NSBundle mainBundle] pathForResource:@"add" ofType:@"png"];
        NSData *addImageData = [NSData dataWithContentsOfFile:filePath];
        [imgAdd setImage:[UIImage imageWithData:addImageData]];
        [btnAdd addSubview:imgAdd];
        [viewHeader addSubview:btnAdd];        
    }
    
    [self setTblHeaderView:viewHeader];

    if ([arrExtensions count] < 2)
    {
        // this is directory
        NSError *error;
        NSArray *dirContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:strPath error:&error];
            
        if (dirContent)
        {
            // show all dirContent items as cell items
            for (int  i = 0; i < [dirContent count]; i++)
            {
                ArchiveMenuModelObject *someFile = [[ArchiveMenuModelObject alloc] initWithFilePath:[strPath stringByAppendingPathComponent:[dirContent objectAtIndex:i]]];
                [tableContent addObject:someFile];
            }
        }
        else
        {
            // TODO: throw error: file path not found
        }
    }
    else
    {
        // view entire archive
        ArchiveMenuModelObject *zipFile = [[ArchiveMenuModelObject alloc] initWithFilePath:strPath];
        [tableContent addObject:zipFile];
    }
    
    return self;
}

- (NSInteger)mainMenuSections
{
    return 1;
}

- (CGFloat)cellHeight:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)mainMenuRowsInSection:(NSInteger)section
{
    return [tableContent count];
}

- (UITableViewCell*)fillCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)indexPath inTableView:(UITableView*)tableView
{    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Archive menu model %d %d", indexPath.section, indexPath.row];
    ArchiveMenuModelContent *cellView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cellView == nil)
    {
        currentTableView = tableView;

        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ArchiveMenuModelContent" owner:self options:nil];
        cellView = (ArchiveMenuModelContent *)[nib objectAtIndex:0];
        
        cellView.selectionStyle = UITableViewCellSelectionStyleNone;
        cellView.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        ArchiveMenuModelObject *cellObject = (ArchiveMenuModelObject *)[tableContent objectAtIndex:indexPath.row];
        
        if (cellObject)
        {
            if (cellObject.title)
            {
                [cellView.title setText:cellObject.title];
            }
            
            if (cellObject.creationDate)
            {
                [cellView.creationDate setText:cellObject.creationDate];
            }
            
            if (cellObject.size)
            {
                [cellView.size setText:cellObject.size];
            }
            
            if (cellObject.typeOrContent)
            {
                [cellView.typeOrContent setText:cellObject.typeOrContent];
            }
            
            if (cellObject.fullFilePath)
            {
                cellView.fullFilePath = [cellObject.fullFilePath copy];
            }
            
            // set image by its file extension
            [cellView.docImageView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:cellObject.strDocImagePath] waitUntilDone:YES];
            
            // initialize btnTick with action and image
            UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(6, 15, 25, 25)] autorelease];
            
            NSArray *arrChildViewControllers = [parentNavigationController viewControllers];
            MenuListController *menuListController = (MenuListController *)[arrChildViewControllers objectAtIndex:1];
            
            BOOL isSelected = NO;
            if (menuListController)
            {
                ArchiveMenuModel *rootArchiveMenuModel = (ArchiveMenuModel *)menuListController.menuModel;
            
                // trim current cell name to common archive tree view path length
                NSString *tmpFolderPath = [NSString stringWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
                tmpFolderPath = [tmpFolderPath stringByDeletingLastPathComponent];
                tmpFolderPath = [tmpFolderPath stringByAppendingPathComponent:@"tmp"];
                int iTmpDirectoryStrLen = [tmpFolderPath length];
                
                NSString *strCurrentCellItemPath = [cellView.fullFilePath substringFromIndex:(iTmpDirectoryStrLen + 1)];
                NSArray *arrPathComponents = [strCurrentCellItemPath componentsSeparatedByString:@"/"];
                
                if ([arrPathComponents count] > 1)
                {
                    // it is NOT a zip archive
                    NSString *firstPathComponent = [arrPathComponents objectAtIndex:0];
                    strCurrentCellItemPath = [strCurrentCellItemPath substringFromIndex:([firstPathComponent length] + 1)];
                        
                    NSArray *arrAllKeys = [rootArchiveMenuModel.dicEntireTreeView allKeys];
                    NSString *strPath;
                    NSNumber *iSelected;
            
                    for (strPath in arrAllKeys)
                    {
                        if ([strPath isEqualToString:strCurrentCellItemPath])
                        {
                            // make checked/unchecked all sub-cell items(in the directory tree view hierarchy)
                            iSelected = (NSNumber *)[rootArchiveMenuModel.dicEntireTreeView objectForKey:strPath];
                            isSelected = [iSelected boolValue];
                        }
                    }
                }
            }

            if (isSelected)
            {
                cellView.checked = YES;
                [imgView setImage:[UIImage imageNamed:@"checked.PNG"]];
            }
            else
            {
                cellView.checked = NO;
                [imgView setImage:[UIImage imageNamed:@"unchecked.PNG"]];
            }

            [cellView.btnTick addSubview:imgView];
            [cellView.btnTick addTarget:self action:@selector(setCellItemSelected:) forControlEvents:UIControlEventTouchUpInside];
            [cellView.btnTick setTitle:[NSString stringWithFormat:@"%d", indexPath.row] forState:UIControlStateNormal];
        }
        else
        {
            // TODO: FUCK! :-)
            return nil;
        }
    }

    return cellView;
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    ArchiveMenuModelContent *cell = (ArchiveMenuModelContent *)[tableView cellForRowAtIndexPath:indexPath];
    
    // determine type of the document by its extension
    if (cell.fullFilePath && ([cell.fullFilePath length] != 0))
    {
        if ([strFilename retainCount])
        {
            [strFilename release];
        }

        strFilename = [cell.fullFilePath copy];        
        NSArray *arrExtensions = [[strFilename lastPathComponent] componentsSeparatedByString:@"."];

        if ([arrExtensions count] < 2)
        {
            // it is an unzipped folder(no extension at all)
            isSubmenu = true;
        }
        else
        {
            [self showConfirmOpenZipAlert];
        }
    }
}

- (void)showConfirmOpenZipAlert
{
    if (!strFilename)
    {
        // TODO: throw alert
    }
    
    // show modal dialog confirmation message
	UIAlertView *alert = [[UIAlertView alloc] init];
    
    NSArray *arrExtensions = [[strFilename lastPathComponent] componentsSeparatedByString:@"."];
    NSString *strExtension = [arrExtensions objectAtIndex:([arrExtensions count] - 1)];

    if ( ([strExtension isEqualToString:@"zip"])
        || ([strExtension isEqualToString:@"ZIP"]) )
    {
        [alert setTitle:NSLocalizedString(@"MM_ALERT_OPEN_ZIP_TITLE", @"MM_ALERT_OPEN_ZIP_TITLE")];
        [alert setMessage:NSLocalizedString(@"MM_ALERT_OPEN_ZIP_MESSAGE", @"MM_ALERT_OPEN_ZIP_MESSAGE")];
        [alert setDelegate:self];
    }
	
    [alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];

	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // at first determine menu action based on file extension
    NSString *strLastPathComponent;
    MenuListController *menuListController;
    ArchiveMenuModel *rootArchiveMenuModel;
    
    if (selectedItems && ![selectedItems count])
    {
        NSArray *arrChildViewControllers = [parentNavigationController viewControllers];
        menuListController = (MenuListController *)[arrChildViewControllers objectAtIndex:1];
        rootArchiveMenuModel = (ArchiveMenuModel *)menuListController.menuModel;
        strLastPathComponent = [[rootArchiveMenuModel.strFilename lastPathComponent] copy];
    }
    else
    {
        strLastPathComponent = [strFilename lastPathComponent];
    }
    
    NSArray *arrExtensions = [strLastPathComponent componentsSeparatedByString:@"."];
    NSString *strExtension = [arrExtensions objectAtIndex:([arrExtensions count] - 1)];

    if ( ([strExtension isEqualToString:@"zip"])
        || ([strExtension isEqualToString:@"ZIP"]) )
    {
        // unarchive it
        // create file paths list (extracted from unzipped archive directory structure)
        NSString *strZipPath = [NSString stringWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        strZipPath = [strZipPath stringByAppendingPathComponent:@"Inbox"];
        strZipPath = [strZipPath stringByAppendingPathComponent:strLastPathComponent];
        
        NSArray *arrExtensions = [strLastPathComponent componentsSeparatedByString:@"."];
        NSString *strExtension = [arrExtensions objectAtIndex:([arrExtensions count] - 1)];

        NSString *outputFolderPath = [NSString stringWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        outputFolderPath = [outputFolderPath stringByDeletingLastPathComponent];
        outputFolderPath = [outputFolderPath stringByAppendingPathComponent:@"tmp"];
        
        outputFolderPath = [outputFolderPath stringByAppendingPathComponent:[strLastPathComponent substringToIndex:([strLastPathComponent length] - [strExtension length] - 1)]]; // trim last four symbols(.zip)

        NSMutableArray *arrFilePaths = [[NSMutableArray alloc] init];
        [archive UnzipOpenFile:strZipPath];
        [archive UnzipFileTo:outputFolderPath overWrite:YES filePaths:arrFilePaths];

        [archive UnzipCloseFile];
        [arrFilePaths release];
        bZipped = NO;

        if (root)
        {
            // build entire directory tree view inside an archive(from root)
            NSFileManager *localFileManager = [[NSFileManager alloc] init];
            NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:outputFolderPath];
            NSArray *arrEntireTreeView = [[NSArray alloc] initWithArray:[dirEnum allObjects]];
            
            // convert arrEntireTreeView to a dictionary(where object - bool value indicates whether was selected table cell item or not
            // and key - arrEntireTreeView path item)
            dicEntireTreeView = [[NSMutableDictionary alloc] init];
            id objectInstance;
            for (objectInstance in arrEntireTreeView)
            {
                [dicEntireTreeView setObject:[NSNumber numberWithBool:NO] forKey:objectInstance];
            }
            
            [arrEntireTreeView release];
        }

        if (buttonIndex == 0)
        {
            // Yes, do something
            // next show unzipped folder
            if (root)
            {
                [self reloadTableWithNewItem:outputFolderPath];                
            }
            else if (rootArchiveMenuModel && menuListController)
            {
                [rootArchiveMenuModel reloadTableWithNewItem:outputFolderPath];
                [parentNavigationController popToViewController:menuListController animated:YES];
            }
            else
            {
                [self reloadTableWithNewItem:outputFolderPath];
            }
        }
        else if (buttonIndex == 1)
        {
            // Selection - Cancel
            if (!selectedItems)
            {
                if (parentNavigationController)
                {
                    // push menu subview controller(archive content table view)
                    MenuListController *subViewController = [[MenuListController alloc] initWithMenuItem:[[[ArchiveMenuModel alloc] initWithFilePath:outputFolderPath isArchive:YES isRoot:NO parentNavController:parentNavigationController] autorelease] andSplitViewController:nil];
                    subViewController.navigationDelegate = self.navigationDelegate;

                    [parentNavigationController pushViewController:subViewController animated:YES];

                    UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(500, 0, 320, 40)];
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
                    [label setFont:[UIFont boldSystemFontOfSize:12.0]];
                    [label setBackgroundColor:[UIColor clearColor]];
                    [label setTextColor:[UIColor whiteColor]];
                    [label setText:[strFilename lastPathComponent]];
                    [labelView addSubview:label];

                    [parentNavigationController.navigationBar.topItem setTitleView:labelView];
                    //[parentNavigationController.navigationBar.topItem setTitle:[strFilename lastPathComponent]];

                    [label release];
                    [subViewController release];
                }
            }
        }
	}
}

-(CommonNavigationItem*)submenuNavigationItemForIndex:(NSIndexPath*)indexPath
{
    if (isSubmenu)
    {
        isSubmenu = false;
        return [[[ArchiveMenuModel alloc] initWithFilePath:strFilename isArchive:bZipped isRoot:NO parentNavController:parentNavigationController] autorelease];
    }

    return nil;
}

- (UIViewController<NavigationSource>*)getDetailControllerForElementAt:(NSIndexPath*)index
{
    return nil;
}

- (void)setCellItemSelected:(id)sender
{
    UIButton *btnSelectCell = (UIButton *)sender;
    UIImageView *imgTickView = (UIImageView *)[[btnSelectCell subviews] objectAtIndex:1];
    
    NSArray *arrChildViewControllers = [parentNavigationController viewControllers];
    MenuListController *menuListController = (MenuListController *)[arrChildViewControllers objectAtIndex:1];
    ArchiveMenuModel *rootArchiveMenuModel = (ArchiveMenuModel *)menuListController.menuModel;
    
    // trim current cell name to common archive tree view path length
    ArchiveMenuModelContent *cell = (ArchiveMenuModelContent *)[currentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[btnSelectCell.titleLabel.text integerValue] inSection:0]];

    NSString *tmpFolderPath = [NSString stringWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    tmpFolderPath = [tmpFolderPath stringByDeletingLastPathComponent];
    tmpFolderPath = [tmpFolderPath stringByAppendingPathComponent:@"tmp"];
    
    int iTmpDirectoryStrLen = [tmpFolderPath length];

    NSString *strCurrentCellItemPath = [cell.fullFilePath substringFromIndex:(iTmpDirectoryStrLen + 1)];
    NSArray *arrPathComponents = [strCurrentCellItemPath componentsSeparatedByString:@"/"];
    NSString *firstPathComponent = [arrPathComponents objectAtIndex:0];
    
    NSArray *arrAllKeys = [rootArchiveMenuModel.dicEntireTreeView allKeys];
    NSString *strPath;
    
    if ([arrPathComponents count] < 2)
    {
        // root element, do checked or unchecked all childrens
        if (cell.checked)
        {
            cell.checked = NO;
            
            for (strPath in arrAllKeys)
            {
                [rootArchiveMenuModel.dicEntireTreeView setObject:[NSNumber numberWithBool:NO] forKey:strPath];
            }
            
            [imgTickView setImage:[UIImage imageNamed:@"unchecked.PNG"]];
        }
        else
        {
            cell.checked = YES;
            
            for (strPath in arrAllKeys)
            {
                [rootArchiveMenuModel.dicEntireTreeView setObject:[NSNumber numberWithBool:YES] forKey:strPath];
            }
            
            [imgTickView setImage:[UIImage imageNamed:@"checked.PNG"]];
        }
    }
    else
    {
        strCurrentCellItemPath = [strCurrentCellItemPath substringFromIndex:([firstPathComponent length] + 1)];

        if (cell.checked)
        {
            cell.checked = NO;
        
            for (strPath in arrAllKeys)
            {
                if ([strPath length] >= [strCurrentCellItemPath length])
                {
                    // 'start with' analog
                    if ([[strPath substringToIndex:[strCurrentCellItemPath length]] isEqualToString:strCurrentCellItemPath])
                    {
                        // make checked/unchecked all sub-cell items(in the directory tree view hierarchy)
                        [rootArchiveMenuModel.dicEntireTreeView setObject:[NSNumber numberWithBool:NO] forKey:strPath];
                    }
                }
            }
        
            [imgTickView setImage:[UIImage imageNamed:@"unchecked.PNG"]];
        }
        else
        {
            cell.checked = YES;

            for (strPath in arrAllKeys)
            {
                if ([strPath length] >= [strCurrentCellItemPath length])
                {
                    // 'start with' analog
                    if ([[strPath substringToIndex:[strCurrentCellItemPath length]] isEqualToString:strCurrentCellItemPath])
                    {
                        // make checked/unchecked all sub-cell items(in the directory tree view hierarchy)
                        [rootArchiveMenuModel.dicEntireTreeView setObject:[NSNumber numberWithBool:YES] forKey:strPath];
                    }
                }
            }

            [imgTickView setImage:[UIImage imageNamed:@"checked.PNG"]];
        }
    }
}

// menu action section
- (void)actionEnciper
{
    
}

- (void)actionEncrypt
{
    
}

- (void)actionZip
{
    
}

- (void)actionOpenIn
{

}

- (void)actionRename
{

}

- (void)actionRemove
{

}

- (void)showConfirmUnzipAllAlert
{
    // show modal dialog confirmation message
	UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:NSLocalizedString(@"MM_ALERT_EXTRACT_ZIP_TITLE", @"MM_ALERT_EXTRACT_ZIP_TITLE")];
    [alert setMessage:NSLocalizedString(@"MM_ALERT_UNZIP_ALL_MESSAGE", @"MM_ALERT_UNZIP_ALL_MESSAGE")];
    [alert setDelegate:self];
	
    [alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];
    
	[alert show];
	[alert release];    
}

- (void)actionExtract
{
    // extract into root folder all selected items
    NSArray *arrChildViewControllers = [parentNavigationController viewControllers];
    MenuListController *menuListController = (MenuListController *)[arrChildViewControllers objectAtIndex:1];
    ArchiveMenuModel *rootArchiveMenuModel = (ArchiveMenuModel *)menuListController.menuModel;

    // create file directory in tmp catalog
    NSString *strFolderName;
    if ([[[rootArchiveMenuModel.strFilename lastPathComponent] componentsSeparatedByString:@"."] count] > 1)
    {
        strFolderName = [[[rootArchiveMenuModel.strFilename lastPathComponent] componentsSeparatedByString:@"."] objectAtIndex:0];
    }
    else
    {
        strFolderName = [rootArchiveMenuModel.strFilename lastPathComponent];
    }

    NSString *strExtractFilePath = [NSString stringWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    strExtractFilePath = [strExtractFilePath stringByDeletingLastPathComponent];
    strExtractFilePath = [strExtractFilePath stringByAppendingPathComponent:@"tmp"];

    NSString *strSourceFilePath = [NSString stringWithString:strExtractFilePath];

    BOOL isDirectory = YES;
    int iCount = 1;
    NSString *strTmpFilePath = [[strExtractFilePath stringByAppendingPathComponent:strFolderName] stringByAppendingString:[[[NSString alloc] initWithFormat:@"-%d", iCount] autorelease]];
    
    while ([[NSFileManager defaultManager] fileExistsAtPath:strTmpFilePath isDirectory:&isDirectory])
    {
        iCount++;
        strTmpFilePath = [[strExtractFilePath stringByAppendingPathComponent:strFolderName] stringByAppendingString:[[[NSString alloc] initWithFormat:@"-%d", iCount] autorelease]];
    }    

    strExtractFilePath = strTmpFilePath;

    NSArray *arrSelItems = (NSArray*)[rootArchiveMenuModel.dicEntireTreeView allKeysForObject:[NSNumber numberWithBool:YES]];
    selectedItems = [arrSelItems copy];
    NSString *someItem;
    
    if ([selectedItems count])
    {
        for (someItem in selectedItems)
        {
            if([[[someItem lastPathComponent] componentsSeparatedByString:@"."] count] > 1)
            {
                // this is a file
                strSourceFilePath = [strSourceFilePath stringByAppendingPathComponent:strFolderName];
                strSourceFilePath = [strSourceFilePath stringByAppendingPathComponent:someItem];
                someItem = [strExtractFilePath stringByAppendingPathComponent:someItem];
            
                // at first create all necessary directories
                NSError *checkError = nil;
                NSDictionary *attrubutes = [NSDictionary dictionaryWithObject:[NSNumber numberWithLong:448] forKey:NSFilePosixPermissions];

                if ([[NSFileManager defaultManager] createDirectoryAtPath:[someItem stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:attrubutes error:&checkError])
                {
                    if (![[NSFileManager defaultManager] createFileAtPath:someItem contents:[NSData dataWithContentsOfFile:strSourceFilePath] attributes:nil])
                    {
                        // TODO:throw error
                    }
                }
                else
                {
                    // TODO:throw error
                }
            }
        }
    
        // pop to first view controller to show unzipped files
        [rootArchiveMenuModel reloadTableWithNewItem:strTmpFilePath];
        [parentNavigationController popToViewController:menuListController animated:YES];
    }
    else
    {
        // show warning
        [self showConfirmUnzipAllAlert];
    }
}

- (void)actionAdd
{
    WizardRearchiveViewController *wizardRearchiveViewController = [[WizardRearchiveViewController alloc] initWithNibName:@"WizardRearchiveViewController" bundle:nil withFolderPath:nil];
    
    NSArray *arrChildViewControllers = [parentNavigationController viewControllers];
    MenuListController *menuListController = (MenuListController *)[arrChildViewControllers objectAtIndex:1];

    [menuListController.mainSplitView setDetailViewController:wizardRearchiveViewController];
}

- (void)reloadTableWithNewItem:(NSString*)strItemPath
{
    ArchiveMenuModelObject *unzippedFolder = [[ArchiveMenuModelObject alloc] initWithFilePath:strItemPath];
    [tableContent addObject:unzippedFolder];
    
    [unzippedFolder release];
    [currentTableView reloadData];
}

- (void)dealloc
{
    [archive release];
    [strFilename release];
    
    if (parentNavigationController)
    {
        [parentNavigationController release];
    }
    
    if (tableContent)
    {   
        [tableContent release];
    }
    
    if (dicEntireTreeView)
    {
        [dicEntireTreeView release];
    }
    
    if (selectedItems)
    {
        [selectedItems release];
    }
    
    [super dealloc];
}

@end

