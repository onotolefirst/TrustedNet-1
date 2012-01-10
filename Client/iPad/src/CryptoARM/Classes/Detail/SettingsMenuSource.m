//
//  MenuSource.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsMenuSource.h"

#import "SettingsMenuItem.h"

@implementation SettingsMenuSource

@synthesize menuPopover;

- (id)initWithTitle:(NSString*)title;
{
    self = [super init];
    if( self )
    {
        menuTitle = title;
        menuItemsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [menuItemsArray release];
    
    [super dealloc];
}

- (NSString*)menuTitle
{
    return menuTitle;
}

- (void)addMenuItem:(NSString*)itemTitle withAction:(SEL)action forTarget:(id)target;
{
    SettingsMenuItem *item = [[SettingsMenuItem alloc] initWithTitle:itemTitle withAction:action forTarget:target];
    [menuItemsArray addObject:item];
    [item release];
}

//- (void)insertMenuItem:(NSUInteger)index
//{
//    
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [menuItemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = ((SettingsMenuItem*)[menuItemsArray objectAtIndex:indexPath.row]).title;

    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SEL itemAction = ((SettingsMenuItem*)[menuItemsArray objectAtIndex:indexPath.row]).action;
    id itemTarget = ((SettingsMenuItem*)[menuItemsArray objectAtIndex:indexPath.row]).target;
    
    if( !itemAction || !itemTarget )
    {
        NSLog(@"Action for this item not defined");
        return;
    }
    
    if( menuPopover )
    {
        [menuPopover dismissPopoverAnimated:YES];
    }
    
    [itemTarget performSelector:itemAction];
}

@end
