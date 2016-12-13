//
//  UBGuestTableViewCell.h
//  Urba
//
//  Created by Ricardo Nazario on 12/6/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UBGuestTableViewCell;

@protocol GuestCellDelegate <NSObject> //this delegate is fired each time you tap the cell

-(void)cancelGuest:(UBGuestTableViewCell *)cell;
-(void)confirmGuest:(UBGuestTableViewCell *)cell;
-(void)listenToStatus:(UBGuestTableViewCell *)cell;

@end

@interface UBGuestTableViewCell : UITableViewCell

@property(weak, nonatomic) id <GuestCellDelegate> delegate; //defining the delegate

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) NSString *visitorId;

- (IBAction)confirmPressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;

@end
