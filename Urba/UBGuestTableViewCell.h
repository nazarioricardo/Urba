//
//  UBGuestTableViewCell.h
//  Urba
//
//  Created by Ricardo Nazario on 12/6/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBUnitViewController.h"

@class UBGuestTableViewCell;

@protocol GuestCellDelegate <NSObject> //this delegate is fired each time you tap the cell

- (void)cancelGuest:(UBGuestTableViewCell *)cell;
//- (void) touchedTheCell:(CellTypeOne *)cell; //if u want t send entire cell this may give error add `@class CellTypeOne;` at the beginning

@end

@interface UBGuestTableViewCell : UITableViewCell

@property(weak, nonatomic) id <GuestCellDelegate> delegate; //defining the delegate

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) NSString *visitorId;

- (IBAction)confirmPressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;

@end
